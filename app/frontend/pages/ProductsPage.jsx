import ProductList from "@/features/products/ProductList";

export default function ProductsPage({ bootstrap }) {
  return (
    <div className="app-shell">
      <header className="app-header">
        <h1>Products</h1>
        <p>{bootstrap.shopOrigin || "Connected shop"}</p>
      </header>

      <section className="panel">
        <h2>Product List</h2>
        <ProductList shopOrigin={bootstrap.shopOrigin} initialProducts={bootstrap.products || []} />
      </section>
    </div>
  );
}
