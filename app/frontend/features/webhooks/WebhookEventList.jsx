import { useEffect, useState } from "react";
import { apiGet } from "@/lib/apiClient";

export default function WebhookEventList() {
  const [events, setEvents] = useState([]);
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let mounted = true;

    apiGet("/api/v1/webhook_events")
      .then((response) => response.json())
      .then((data) => {
        if (!mounted) return;
        setEvents(data.events || []);
      })
      .catch(() => {
        if (!mounted) return;
        setError("Unable to load webhook events");
      })
      .finally(() => {
        if (!mounted) return;
        setLoading(false);
      });

    return () => {
      mounted = false;
    };
  }, []);

  if (loading) return <p>Loading webhook events...</p>;
  if (error) return <p>{error}</p>;
  if (events.length === 0) return <p>No webhook events captured yet.</p>;

  return (
    <ul className="entity-list">
      {events.map((event) => (
        <li key={event.webhook_id}>
          <strong>{event.topic}</strong>
          <span>{new Date(event.received_at).toLocaleString()}</span>
        </li>
      ))}
    </ul>
  );
}
