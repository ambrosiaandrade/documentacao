# Exportar arquivos

## 📚 Tabela de conteúdos

- [📦 Dependências](#dependências)
- [🧪 Gerando CSV com StringWriter](#gerando-csv-com-stringwriter)
- [📄 Gerando PDF com ByteArrayOutputStream](#gerando-pdf-com-bytearrayoutputstream)
- [🧠 StringWriter vs ByteArrayOutputStream](#stringwriter-vs-bytearrayoutputstream)
- [🌐 Exemplos de Headers HTTP](#exemplos-de-headers-http)

## 📦 Dependências

```xml
<dependency>
  <groupId>com.opencsv</groupId>
  <artifactId>opencsv</artifactId>
</dependency>

<dependency>
  <groupId>com.github.librepdf</groupId>
  <artifactId>openpdf</artifactId>
</dependency>
```

---

## 🧪 Gerando CSV com StringWriter

```java
StringWriter writer = new StringWriter();
CSVWriter csvWriter = new CSVWriter(writer);

csvWriter.writeNext(new String[]{"name", "age"});
for (Animal a : repository.findAll()) {
    csvWriter.writeNext(new String[]{a.getName(), a.getAge()});
}
csvWriter.close();

return writer.toString().getBytes(StandardCharsets.UTF_8);
```

**Headers no Controller:**

```java
HttpHeaders headers = new HttpHeaders();
headers.set(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=alunos.csv");
headers.set(HttpHeaders.CONTENT_TYPE, "text/csv; charset=UTF-8");
```

---

## 📄 Gerando PDF com ByteArrayOutputStream

```java
try (ByteArrayOutputStream baos = new ByteArrayOutputStream()) {
    Document doc = new Document();
    PdfWriter.getInstance(doc, baos);
    doc.open();

    doc.add(new Paragraph("Report"));
    doc.add(Chunk.NEWLINE);

    PdfPTable table = new PdfPTable(2);
    table.addCell("name");
    table.addCell("age");

    for (Animal a : repository.findAll()) {
        table.addCell(a.getName());
        table.addCell(String.valueOf(a.getAge()));
    }

    doc.close();
    return baos.toByteArray();
}
```

**Headers no Controller:**

```java
HttpHeaders headers = new HttpHeaders();
headers.set(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=pets.pdf");
headers.set(HttpHeaders.CONTENT_TYPE, "application/pdf");
```

---

## 🧠 StringWriter vs ByteArrayOutputStream

| Situação                    | Writer Ideal                                | Exemplo de Formato  |
| --------------------------- | ------------------------------------------- | ------------------- |
| Texto puro                  | `StringWriter`                              | CSV, JSON, XML      |
| Binário (PDF, imagens etc.) | `ByteArrayOutputStream`                     | PDF, PNG, ZIP, DOCX |
| **Dica**                    | Use `ByteArrayOutputStream` se tiver dúvida |                     |

---

## 🌐 Exemplos de Headers HTTP

**Request:**

```
GET /api/dados HTTP/1.1
Content-Type: application/json
Authorization: Bearer <token>
```

**Response:**

```
HTTP/1.1 200 OK
Content-Type: application/pdf
Content-Disposition: attachment; filename="relatorio.pdf"
```
