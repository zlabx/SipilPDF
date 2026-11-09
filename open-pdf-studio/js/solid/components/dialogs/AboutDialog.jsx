import { createSignal, onMount } from 'solid-js';
import Dialog from '../Dialog.jsx';
import { closeDialog } from '../../stores/dialogStore.js';
import { getAppVersion } from '../../../core/platform.js';
import { openExtern } from '../../../core/extern-openen.js';
import { useTranslation } from '../../../i18n/useTranslation.js';
// Als asset geïmporteerd: Vite zet de bouwbasis ervoor (#545).
import appIcoon from '/icon.png';

export default function AboutDialog() {
  const { t } = useTranslation('appMenu');
  const [version, setVersion] = createSignal(t('aboutPanel.version'));

  // SipilPDF shows its own version (brand.json display_version), not the upstream calendar version.
  onMount(() => {
    setVersion(`${t('aboutPanel.version')} 2027.0`);
  });

  const close = () => closeDialog('about');

  return (
    <Dialog
      title={t('aboutPanel.title')}
      dialogClass="about-dialog"
      onClose={close}
    >
      <div class="bs-about-panel">
        <div class="bs-about-app">
          <div class="bs-about-logo">
            <img src={appIcoon} alt="Open PDF Studio" />
          </div>
          <div class="bs-about-app-info">
            <h1 class="bs-about-app-name">{t('aboutPanel.appName')}</h1>
            <p class="bs-about-version">{version()}</p>
            <p class="bs-about-tagline">{t('aboutPanel.tagline')}</p>
          </div>
        </div>

        <p class="bs-about-description">
          SipilPDF is a PDF viewer and editor by SipilStock, based on Open PDF Studio.
        </p>

        <div class="bs-about-links">
          <a href="#" class="bs-about-link" onClick={(e) => { e.preventDefault(); openExtern('https://github.com/zlabx/SipilPDF'); }}>Source code</a>
          <a href="#" class="bs-about-link" onClick={(e) => { e.preventDefault(); openExtern('https://github.com/OpenAEC-Foundation/open-pdf-studio'); }}>Upstream</a>
          <a href="#" class="bs-about-link" onClick={(e) => { e.preventDefault(); openExtern('https://github.com/zlabx/SipilPDF/blob/main/LICENSE.md'); }}>License (LGPL-3.0)</a>
          <a href="#" class="bs-about-link" onClick={(e) => { e.preventDefault(); openExtern('https://github.com/zlabx/SipilPDF/blob/main/MODIFICATIONS.md'); }}>Changes</a>
        </div>

        <div class="bs-about-footer">
          <p class="bs-about-license">LGPL-3.0-or-later. The combined work also contains AGPL-3.0 code (MuPDF); see LICENSING.md in the source.</p>
        </div>
      </div>
    </Dialog>
  );
}
