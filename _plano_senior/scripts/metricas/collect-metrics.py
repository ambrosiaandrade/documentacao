#!/usr/bin/env python3
"""
Coletar métricas de qualidade de testes de múltiplas fontes.

Uso:
    python3 collect-metrics.py

Saída:
    target/quality-report.json
"""

import xml.etree.ElementTree as ET
import json
import sys
import os
from datetime import datetime
from pathlib import Path


def parse_jacoco(file_path):
    """Extrair métricas de cobertura do JaCoCo"""
    try:
        tree = ET.parse(file_path)
        root = tree.getroot()
        
        counters = {}
        for counter in root.findall('.//counter'):
            type_ = counter.get('type')
            missed = int(counter.get('missed', 0))
            covered = int(counter.get('covered', 0))
            total = missed + covered
            
            if total > 0:
                counters[type_.lower()] = {
                    'covered': covered,
                    'missed': missed,
                    'total': total,
                    'percentage': round((covered / total) * 100, 2)
                }
        
        return counters
    except FileNotFoundError:
        print(f"⚠️  JaCoCo report not found: {file_path}", file=sys.stderr)
        return {}
    except Exception as e:
        print(f"⚠️  Error parsing JaCoCo: {e}", file=sys.stderr)
        return {}


def parse_pitest(file_path):
    """Extrair mutation score do PITest"""
    try:
        tree = ET.parse(file_path)
        root = tree.getroot()
        
        mutations = root.findall('.//mutation')
        
        killed = sum(1 for m in mutations if m.get('status') == 'KILLED')
        survived = sum(1 for m in mutations if m.get('status') == 'SURVIVED')
        no_coverage = sum(1 for m in mutations if m.get('status') == 'NO_COVERAGE')
        total = len(mutations)
        
        return {
            'killed': killed,
            'survived': survived,
            'no_coverage': no_coverage,
            'total': total,
            'score': round((killed / total) * 100, 2) if total > 0 else 0
        }
    except FileNotFoundError:
        print(f"⚠️  PITest report not found: {file_path}", file=sys.stderr)
        return {}
    except Exception as e:
        print(f"⚠️  Error parsing PITest: {e}", file=sys.stderr)
        return {}


def parse_surefire(directory):
    """Extrair resultados de testes do Surefire"""
    try:
        xml_files = list(Path(directory).glob('*.xml'))
        
        if not xml_files:
            print(f"⚠️  No Surefire reports found in: {directory}", file=sys.stderr)
            return {}
        
        tests = 0
        failures = 0
        errors = 0
        skipped = 0
        time = 0.0
        
        for xml_file in xml_files:
            try:
                tree = ET.parse(xml_file)
                root = tree.getroot()
                
                tests += int(root.get('tests', 0))
                failures += int(root.get('failures', 0))
                errors += int(root.get('errors', 0))
                skipped += int(root.get('skipped', 0))
                time += float(root.get('time', 0))
            except Exception as e:
                print(f"⚠️  Error parsing {xml_file}: {e}", file=sys.stderr)
                continue
        
        passed = tests - failures - errors - skipped
        
        return {
            'tests': tests,
            'failures': failures,
            'errors': errors,
            'skipped': skipped,
            'passed': passed,
            'time_seconds': round(time, 2),
            'success_rate': round((passed / tests) * 100, 2) if tests > 0 else 0
        }
    except Exception as e:
        print(f"⚠️  Error parsing Surefire: {e}", file=sys.stderr)
        return {}


def generate_report():
    """Gerar relatório consolidado"""
    report = {
        'timestamp': datetime.now().isoformat(),
        'coverage': {},
        'mutation': {},
        'tests': {},
        'metadata': {
            'version': '1.0',
            'generator': 'collect-metrics.py'
        }
    }
    
    # JaCoCo
    jacoco_path = 'target/site/jacoco/jacoco.xml'
    if os.path.exists(jacoco_path):
        report['coverage'] = parse_jacoco(jacoco_path)
    
    # PITest
    pitest_path = 'target/pit-reports/mutations.xml'
    if os.path.exists(pitest_path):
        report['mutation'] = parse_pitest(pitest_path)
    
    # Surefire
    surefire_dir = 'target/surefire-reports'
    if os.path.exists(surefire_dir):
        report['tests'] = parse_surefire(surefire_dir)
    
    return report


def print_report(report):
    """Imprimir relatório formatado no console"""
    print("=" * 60)
    print("📊 QUALITY METRICS REPORT")
    print("=" * 60)
    print(f"Generated: {report['timestamp']}")
    print()
    
    # Tests
    if report.get('tests') and report['tests']:
        t = report['tests']
        success_emoji = "✅" if t['success_rate'] == 100 else "⚠️" if t['success_rate'] >= 90 else "❌"
        
        print("🧪 Tests:")
        print(f"   Total: {t['tests']}")
        print(f"   Passed: {t['passed']} ({t['success_rate']}%) {success_emoji}")
        print(f"   Failed: {t['failures'] + t['errors']}")
        print(f"   Skipped: {t['skipped']}")
        print(f"   Duration: {t['time_seconds']}s")
        print()
    
    # Coverage
    if report.get('coverage') and report['coverage']:
        print("📈 Coverage:")
        for type_, data in report['coverage'].items():
            coverage_emoji = "✅" if data['percentage'] >= 80 else "⚠️" if data['percentage'] >= 60 else "❌"
            print(f"   {type_.capitalize()}: {data['percentage']}% ({data['covered']}/{data['total']}) {coverage_emoji}")
        print()
    
    # Mutation
    if report.get('mutation') and report['mutation']:
        m = report['mutation']
        mutation_emoji = "✅" if m['score'] >= 70 else "⚠️" if m['score'] >= 50 else "❌"
        
        print("🧬 Mutation Testing:")
        print(f"   Score: {m['score']}% {mutation_emoji}")
        print(f"   Killed: {m['killed']}")
        print(f"   Survived: {m['survived']}")
        print(f"   No Coverage: {m['no_coverage']}")
        print(f"   Total: {m['total']}")
        print()
    
    print("=" * 60)


def check_thresholds(report):
    """Verificar se métricas atendem thresholds"""
    failures = []
    
    # Coverage threshold
    line_coverage = report.get('coverage', {}).get('line', {}).get('percentage', 0)
    if line_coverage < 80:
        failures.append(f"Line coverage ({line_coverage}%) < 80%")
    
    # Mutation threshold
    mutation_score = report.get('mutation', {}).get('score', 0)
    if mutation_score > 0 and mutation_score < 70:
        failures.append(f"Mutation score ({mutation_score}%) < 70%")
    
    # Test success rate
    success_rate = report.get('tests', {}).get('success_rate', 0)
    if success_rate < 100:
        failures.append(f"Test success rate ({success_rate}%) < 100%")
    
    return failures


def save_to_history(report):
    """Salvar no histórico diário"""
    history_dir = Path('metrics-history')
    history_dir.mkdir(exist_ok=True)
    
    date_str = datetime.now().strftime('%Y-%m-%d')
    history_file = history_dir / f'{date_str}.json'
    
    with open(history_file, 'w') as f:
        json.dump(report, f, indent=2)
    
    print(f"📁 Saved to history: {history_file}")


def main():
    """Main function"""
    print("🔍 Collecting quality metrics...")
    print()
    
    report = generate_report()
    
    # Criar diretório de saída
    output_dir = Path('target')
    output_dir.mkdir(exist_ok=True)
    
    # Salvar JSON
    output_file = output_dir / 'quality-report.json'
    with open(output_file, 'w') as f:
        json.dump(report, f, indent=2)
    
    print(f"💾 Report saved to: {output_file}")
    print()
    
    # Imprimir no console
    print_report(report)
    
    # Verificar thresholds
    failures = check_thresholds(report)
    
    print()
    if failures:
        print("❌ Quality thresholds not met:")
        for failure in failures:
            print(f"   - {failure}")
        print()
        
        # Salvar no histórico mesmo com falha
        save_to_history(report)
        
        return 1
    else:
        print("✅ All quality thresholds met!")
        print()
        
        # Salvar no histórico
        save_to_history(report)
        
        return 0


if __name__ == '__main__':
    sys.exit(main())
