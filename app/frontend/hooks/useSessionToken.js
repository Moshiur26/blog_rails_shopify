import { useEffect, useState } from "react";
import { fetchSessionToken } from "@/lib/shopifyAppBridge";

export default function useSessionToken() {
  const [token, setToken] = useState("");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    let mounted = true;

    fetchSessionToken()
      .then((sessionToken) => {
        if (!mounted) return;
        setToken(sessionToken);
      })
      .catch((err) => {
        if (!mounted) return;
        setError(err);
      })
      .finally(() => {
        if (!mounted) return;
        setLoading(false);
      });

    return () => {
      mounted = false;
    };
  }, []);

  return { token, loading, error };
}
