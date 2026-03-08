import ProductList from "@/features/products/ProductList";
import WebhookEventList from "@/features/webhooks/WebhookEventList";

export default function App({ bootstrap }) {
  return (
    <div className="app-shell">
      <header className="app-header">
        <h1>Shopify Admin Dashboard</h1>
        <p>{bootstrap.shopOrigin || "Connected shop"}</p>
      </header>

      <section className="panel">
        <h2>Products</h2>
        <ProductList shopOrigin={bootstrap.shopOrigin} />
      </section>

      <section className="panel">
        <h2>Webhook Events</h2>
        <WebhookEventList />
      </section>
    </div>
  );
}
