# Modifications

SipilPDF 2027.0 is derived from Open PDF Studio (OpenAEC Foundation), licensed under the GNU LGPL v3 or later.
The files below were changed by SipilStock. Everything else is upstream's, unchanged.

- Product name, application id (`com.sipilstock.sipilpdf`), window title and file-association names: `Open PDF Studio` ->
  `SipilPDF` in the frontend (`open-pdf-studio/js`, `styles`, `index.html`, `public`, `scripts`), the native
  source (`open-pdf-studio/src-tauri/src`) and the Tauri configuration. Technical names (`open-pdf-studio`,
  `pdfium-worker`) are unchanged.
- Upstream repository links in the code now point to https://github.com/zlabx/SipilPDF.
- About dialog reduced to a short page with the licence and source links and the SipilPDF version
  (`open-pdf-studio/js/solid/components/dialogs/AboutDialog.jsx`).
- Services on other hosts (feedback service, online symbol library, release notes) are off in every build
  (`open-pdf-studio/js/core/webfuncties.js`).
- Managed mode is always on in the desktop app (`open-pdf-studio/src-tauri/src/beheerd.rs`): no check of
  upstream's releases and no update window or first-run prompts; updates come through SipilStock Apps.
- Icons replaced by the SipilPDF icon set (PNG, ICO, ICNS, SVG).
- `README.md` replaced (upstream's is `README.upstream.md`); this file, `BUILD.md`, `SIPIL_VERSION` and the Windows installer script `packaging/windows/sipilpdf.iss` added.
- Not committed here: upstream's CI definitions, committed build output, test PDFs, promo material.

Changed files by the text substitution: 335 (listed in the build log).
