import { useEffect, useState } from "react";
import { apiGet } from "@/lib/apiClient";

export default function ProductList({ shopOrigin, initialProducts = [] }) {
  const [products, setProducts] = useState(initialProducts);
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(initialProducts.length === 0);

  useEffect(() => {
    let mounted = true;

    apiGet("/api/v1/products")
      .then((response) => response.json())
      .then((data) => {
        if (!mounted) return;
        setProducts(data.products || []);
      })
      .catch(() => {
        if (!mounted) return;
        setError("Unable to load products");
      })
      .finally(() => {
        if (!mounted) return;
        setLoading(false);
      });

    return () => {
      mounted = false;
    };
  }, []);

  if (loading) return <p>Loading products...</p>;
  if (error) return <p>{error}</p>;
  if (products.length === 0) return <p>No products found.</p>;

  return (
    <ul className="entity-list">
      {products.map((product) => (
        <li key={product.id}>
          <a
            href={`https://${shopOrigin}/admin/products/${product.id}`}
            target="_top"
            rel="noreferrer"
          >
            {product.title}
          </a>
        </li>
      ))}
    </ul>
  );
}
