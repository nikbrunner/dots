# Fetch Wrapper

## Principle

A single source of truth for all HTTP requests. Every query and mutation uses this wrapper.

```tsx
// lib/api/client.ts
const API_BASE_URL = import.meta.env.VITE_API_BASE_URL;

interface RequestOptions extends Omit<RequestInit, "body"> {
  body?: unknown;
}

export async function apiClient<T>(
  endpoint: string,
  options: RequestOptions = {},
): Promise<T> {
  const { body, headers, ...rest } = options;

  const response = await fetch(`${API_BASE_URL}${endpoint}`, {
    headers: {
      "Content-Type": "application/json",
      ...getAuthHeaders(),
      ...headers,
    },
    body: body ? JSON.stringify(body) : undefined,
    ...rest,
  });

  if (!response.ok) {
    throw new ApiError(response.status, await response.text());
  }

  return response.json();
}
```

## What It Handles

- Base URL configuration
- Auth headers (token injection)
- Content-Type defaults
- Error normalization (consistent error shape)
- Response parsing

## What It Does NOT Handle

- Retries (TanStack Query handles this)
- Caching (TanStack Query handles this)
- Loading states (TanStack Query handles this)
