function getInitData() {
  const node = document.getElementById("shopify-app-init");
  if (!node) throw new Error("Missing #shopify-app-init element");

  return node.dataset;
}

function getShopifyApp() {
  if (window.app) return window.app;

  const data = getInitData();
  const AppBridge = window["app-bridge"];

  if (!AppBridge || !AppBridge.default) {
    throw new Error("Shopify App Bridge is unavailable");
  }

  window.app = AppBridge.default({
    apiKey: data.apiKey,
    host: data.host,
    forceRedirect: true
  });

  return window.app;
}

export async function fetchSessionToken() {
  const app = getShopifyApp();
  const SessionToken = window["app-bridge"].actions.SessionToken;

  app.dispatch(SessionToken.request());

  return new Promise((resolve) => {
    app.subscribe(SessionToken.Action.RESPOND, ({ sessionToken }) => {
      resolve(sessionToken || "");
    });
  });
}
