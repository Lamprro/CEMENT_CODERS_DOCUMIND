const MIME_BY_EXT: Record<string, string> = {
    pdf: "application/pdf",
    docx: "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    txt: "text/plain",
    csv: "text/csv",
    log: "text/plain",
    cs: "text/x-csharp",
    md: "text/markdown",
    markdown: "text/markdown",
    json: "application/json",
    js: "text/javascript",
    jsx: "text/javascript",
    ts: "text/typescript",
    tsx: "text/typescript",
    py: "text/x-python",
    java: "text/x-java-source",
    sql: "application/sql",
    html: "text/html",
    css: "text/css",
    xml: "application/xml",
    yaml: "application/yaml",
    yml: "application/yaml",
    sh: "application/x-sh",
    go: "text/x-go",
    rs: "text/x-rust",
    c: "text/x-c",
    cpp: "text/x-c++",
    h: "text/x-c",
    png: "image/png",
    jpg: "image/jpeg",
    jpeg: "image/jpeg",
};

export function mimeTypeForFilename(name: string) {
    return MIME_BY_EXT[name.split(".").pop()?.toLowerCase() ?? ""] ?? null;
}

export function normalizeText(value: string) {
    return (value
        .normalize("NFC")
        .replace(/\r\n?/g, "\n")
        .replace(/[\uFEFF\u200B-\u200D\u2060\u00AD]/g, "")
        .replace(/[\u00A0\u2007\u202F]/g, " ")
        .replace(/[\u0000-\u0008\u000B\u000C\u000E-\u001F]/g, " ")
        .split("\n")
        .map((line) => {
        const indent = /^[ \t]*/.exec(line)![0];
        return (indent.replace(/\t/g, "    ") +
            line
                .slice(indent.length)
                .replace(/[ \t]+/g, " ")
                .trimEnd());
    })
        .join("\n")
        .replace(/\n{3,}/g, "\n\n")
        .replace(/^\s+/, "")
        .trimEnd());
}
