import { useEffect, useState } from "react";
import useSessionToken from "@/hooks/useSessionToken";
import { apiGet } from "@/lib/apiClient";

export default function ProductList({ shopOrigin }) {
  const { token, loading: tokenLoading, error: tokenError } = useSessionToken();
  const [products, setProducts] = useState([]);
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (tokenLoading || tokenError || !token) return;

    let mounted = true;

    apiGet("/api/v1/products", token)
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
  }, [token, tokenError, tokenLoading]);

  if (tokenLoading || loading) return <p>Loading products...</p>;
  if (tokenError || error) return <p>{error || "Authorization failed"}</p>;
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
