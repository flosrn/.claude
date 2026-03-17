# Next.js Review Checklist

## App Router & File Structure

- [ ] Correct use of `app/` directory (not `pages/`)
- [ ] Route segments follow naming: `(group)`, `[dynamic]`, `[[...slug]]`
- [ ] `layout.tsx` properly structured (not duplicating layouts)
- [ ] `page.tsx` is actual page content
- [ ] `error.tsx` exists for error boundaries
- [ ] `loading.tsx` for Suspense fallbacks
- [ ] `not-found.tsx` for 404 handling
- [ ] `route.ts` for API routes with proper method handlers

## Server vs Client Boundaries

- [ ] `'use client'` only on leaf components (not root layouts)
- [ ] Interactivity at lowest component level
- [ ] No `'use client'` for data fetching (use server components)
- [ ] Heavy computations in server components
- [ ] Client components don't contain layout logic
- [ ] Props passed from server to client are serializable

## Data Fetching

- [ ] `async` components used for server-side fetching
- [ ] No blocking cascade of serial fetches (parallel with `Promise.all`)
- [ ] Fetch requests cached properly (default `cache: 'force-cache'`)
- [ ] Dynamic data uses `revalidate` or `cache: 'no-store'`
- [ ] API routes don't block request (use async handlers)
- [ ] No fetching in event handlers

## Bundle Optimization

- [ ] Large dependencies lazy-loaded (`dynamic()`)
- [ ] `next/image` used for images (not `<img>`)
- [ ] Image dimensions specified
- [ ] SVGs imported as React components when possible
- [ ] Code splitting at route level (automatic)
- [ ] No unused imports

## Caching Strategy

- [ ] Responses cached appropriately (ISR, PPR, or static)
- [ ] `revalidatePath()` used for incremental revalidation
- [ ] `revalidateTag()` for granular cache invalidation
- [ ] ISR paths configured correctly (`revalidate: N`)
- [ ] `use cache` directive for function-level caching (Next.js 16+)
- [ ] `cacheLife` configured for appropriate duration

## Middleware & Edge

- [ ] Middleware placed in `middleware.ts` (root)
- [ ] Route matching correct (`matcher` config)
- [ ] No heavy computations in middleware
- [ ] Request/response headers modified safely
- [ ] Redirects use `NextResponse.redirect()`
- [ ] Edge runtime compatible code only

## Metadata & SEO

- [ ] `metadata` export in layouts/pages
- [ ] Open Graph tags included
- [ ] Twitter Card tags included
- [ ] Canonical URLs set
- [ ] Robots.txt configured
- [ ] Sitemap.xml generated

## Error Handling

- [ ] `error.tsx` catches server component errors
- [ ] `not-found.tsx` for 404s
- [ ] Global error handler in `app/error.tsx`
- [ ] Errors logged appropriately
- [ ] User-friendly error messages
- [ ] Stack traces not exposed to client

## API Routes (`app/api/`)

- [ ] GET, POST, PUT, DELETE exported properly
- [ ] No request body in GET requests
- [ ] Auth checks before data access
- [ ] Input validation on all endpoints
- [ ] Proper status codes (200, 201, 400, 401, 404, 500)
- [ ] CORS configured if needed
- [ ] Rate limiting considered

## Performance

- [ ] Font optimization (`next/font`)
- [ ] Web fonts loaded efficiently
- [ ] LCP < 2.5s (Largest Contentful Paint)
- [ ] CLS < 0.1 (Cumulative Layout Shift)
- [ ] Images lazy-loaded with `priority` only for critical
- [ ] No render-blocking resources

## Development vs Production

- [ ] No `console.log()` in production code
- [ ] Environment variables in `.env.local`
- [ ] Secrets not in version control
- [ ] Build succeeds without warnings
- [ ] Type checking passes (`tsc --noEmit`)

## Common Pitfalls

- Using `useState` for persistent data (use server components)
- Fetching in `useEffect` (use server components)
- Large `'use client'` wrapper (split components)
- Synchronous data fetching (use `async` functions)
- Blocking parallel requests (use `Promise.all`)
- Image without `next/image` (causes bundle bloat)
- Missing `key` props in lists
- Client mutations without server action calls

## Testing in Next.js

- [ ] Static routes tested for build
- [ ] Dynamic routes tested with parameters
- [ ] API routes tested with proper headers
- [ ] Middleware tested with matched routes
- [ ] Redirects verified
- [ ] 404 pages serve correct status code
