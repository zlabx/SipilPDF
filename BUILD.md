# Building SipilPDF

This repository is generated (see README.md). It is the complete corresponding source of SipilPDF: the web version
and the Windows desktop version are built from it.

## Web version (hosted bundle)

    cd open-pdf-studio
    npm ci
    npx vite build --mode hosted --base=./ --outDir ../dist/sipilpdf/web --emptyOutDir

Node 22. The output is a static site that works from any sub-path.

## Windows desktop version

Windows x64 with the Microsoft C++ build tools, Rust (stable), Node 22 and CMake (Tesseract and Leptonica are compiled
from source and linked statically). From the repository root:

    cd open-pdf-studio
    npm ci
    cd ..
    cargo build --release -p pdfium-worker -p open-pdf-thumbnails
    copy target\release\pdfium-worker.exe open-pdf-studio\src-tauri\binaries\pdfium-worker-x86_64-pc-windows-msvc.exe
    copy target\release\open_pdf_thumbnails.dll open-pdf-studio\src-tauri\binaries\open-pdf-thumbnails.dll
    cd open-pdf-studio
    npx tauri build --no-bundle -- --locked

`npm run build` (run by `tauri build`) downloads PDFium and the OCR data first (scripts/native-runtime.mjs and
scripts/ocr-runtime.mjs). The result is `target\release\open-pdf-studio.exe` next to `pdfium-worker.exe`. The folder
that the installer lays out (exe, sidecar, DLLs, resource folders) is assembled by `node scripts/draagbare-zip.mjs`
(without `portable.ini` and `README.txt`); the exe is installed as `SipilPDF.exe`.

The installer is built with Inno Setup from `packaging/windows/sipilpdf.iss` (per-user install, no administrator
rights). The CI workflow that does all of this is
<https://github.com/zlabx/Apps/blob/main/.github/workflows/sipilpdf-desktop.yml> and the version is in
`SIPIL_VERSION`.
