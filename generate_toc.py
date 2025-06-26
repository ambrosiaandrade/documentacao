import re

def slugify(text):
    # Remove emojis, pontuação, acentos e converte espaços em hífens
    text = re.sub(r'[^\w\s-]', '', text, flags=re.UNICODE)  # remove pontuação
    text = re.sub(r'\s+', '-', text.strip().lower())  # espaços -> hífen
    return text

def gerar_toc(markdown_text):
    toc = []
    lines = markdown_text.splitlines()
    for line in lines:
        match = re.match(r'^(#{2,6})\s+(.*)', line)
        if match:
            level = len(match.group(1)) - 1  # ignora o nível 1 (#)
            title = match.group(2).strip()
            anchor = slugify(title)
            indent = '  ' * (level - 1)
            toc.append(f"{indent}- [{title}](#{anchor})")
    return '\n'.join(toc)

# 👇 Exemplo de uso
if __name__ == "__main__":
    with open("spring-actuator.md", "r", encoding="utf-8") as f:
        markdown_content = f.read()
    toc = gerar_toc(markdown_content)
    print("## 📚 Tabela de conteúdos\n")
    print(toc)
