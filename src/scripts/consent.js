/*
 * Cookie choice for Google Analytics.
 *
 * The tag is not on the page until a reader allows it. A stored choice is
 * theirs and always wins, so a returning visitor is not asked again. Declining
 * loads nothing from Google; allowing loads the tag for this page and the
 * next. The choice can be changed from the quiet control at the foot of the
 * column.
 */

const STORAGE_KEY = "analytics-consent";
const GRANTED = "granted";
const DENIED = "denied";

const banner = document.querySelector(".consent");
const foot = document.querySelector(".consent-foot");
const gaId = /^G-[A-Z0-9]+$/.test(banner?.dataset.gaId ?? "")
  ? banner.dataset.gaId
  : "";

const read = () => {
  try {
    return localStorage.getItem(STORAGE_KEY);
  } catch {
    return null;
  }
};

const write = (value) => {
  try {
    localStorage.setItem(STORAGE_KEY, value);
  } catch {
    /* The choice will not survive the session, but it holds for this page. */
  }
};

function showBanner(visible) {
  if (banner) banner.hidden = !visible;
  if (foot) foot.hidden = visible;
}

function loadAnalytics() {
  if (!gaId || typeof window.gtag === "function") return;

  window.dataLayer = window.dataLayer || [];
  window.gtag = function gtag() {
    window.dataLayer.push(arguments);
  };
  window.gtag("consent", "update", {
    analytics_storage: "granted",
    ad_storage: "denied",
    ad_user_data: "denied",
    ad_personalization: "denied",
  });
  window.gtag("js", new Date());
  window.gtag("config", gaId, {
    allow_google_signals: false,
    allow_ad_personalization_signals: false,
  });

  const script = document.createElement("script");
  script.async = true;
  script.src = `https://www.googletagmanager.com/gtag/js?id=${gaId}`;
  document.head.appendChild(script);
}

function denyAnalytics() {
  if (typeof window.gtag === "function") {
    window.gtag("consent", "update", {
      analytics_storage: "denied",
      ad_storage: "denied",
      ad_user_data: "denied",
      ad_personalization: "denied",
    });
  }
}

function decide(value) {
  write(value);
  if (value === GRANTED) loadAnalytics();
  else denyAnalytics();
  showBanner(false);
}

const stored = read();
if (stored === GRANTED) {
  loadAnalytics();
  showBanner(false);
} else if (stored === DENIED) {
  showBanner(false);
} else {
  showBanner(true);
}

banner?.querySelector(".consent-allow")?.addEventListener("click", () => {
  decide(GRANTED);
});
banner?.querySelector(".consent-decline")?.addEventListener("click", () => {
  decide(DENIED);
});
foot?.querySelector(".consent-reopen")?.addEventListener("click", () => {
  showBanner(true);
});
