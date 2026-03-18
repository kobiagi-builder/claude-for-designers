#!/usr/bin/env python3
"""
Capture reference screenshots from best-in-class products.
Uses Playwright to navigate to product pages and take screenshots.
Each product gets 3 screenshots: homepage, key feature page, and pricing/detail page.
"""

import asyncio
import os
import json
import subprocess
import sys

try:
    from playwright.async_api import async_playwright
except ImportError:
    print("Installing playwright...")
    subprocess.check_call([sys.executable, "-m", "pip", "install", "playwright"])
    subprocess.check_call([sys.executable, "-m", "playwright", "install", "chromium"])
    from playwright.async_api import async_playwright

REFERENCES_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "references")

# Product definitions: vertical -> [{name, folder, urls: [url1, url2, url3], labels: [label1, label2, label3]}]
PRODUCTS = {
    "fintech": [
        {"name": "Stripe", "folder": "stripe", "urls": [
            "https://stripe.com", "https://stripe.com/payments", "https://stripe.com/pricing"
        ], "labels": ["homepage", "payments-feature", "pricing"]},
        {"name": "Wise", "folder": "wise", "urls": [
            "https://wise.com", "https://wise.com/us/send-money", "https://wise.com/pricing"
        ], "labels": ["homepage", "send-money", "pricing"]},
        {"name": "Mercury", "folder": "mercury", "urls": [
            "https://mercury.com", "https://mercury.com/features", "https://mercury.com/pricing"
        ], "labels": ["homepage", "features", "pricing"]},
    ],
    "healthtech": [
        {"name": "Zocdoc", "folder": "zocdoc", "urls": [
            "https://www.zocdoc.com", "https://www.zocdoc.com/about", "https://www.zocdoc.com/care"
        ], "labels": ["homepage", "about", "care"]},
        {"name": "Headspace", "folder": "headspace", "urls": [
            "https://www.headspace.com", "https://www.headspace.com/meditation", "https://www.headspace.com/subscriptions"
        ], "labels": ["homepage", "meditation", "subscriptions"]},
        {"name": "One Medical", "folder": "one-medical", "urls": [
            "https://www.onemedical.com", "https://www.onemedical.com/why-one-medical", "https://www.onemedical.com/locations"
        ], "labels": ["homepage", "why-one-medical", "locations"]},
    ],
    "ecommerce": [
        {"name": "Shopify", "folder": "shopify", "urls": [
            "https://www.shopify.com", "https://www.shopify.com/online", "https://www.shopify.com/pricing"
        ], "labels": ["homepage", "online-store", "pricing"]},
        {"name": "Gumroad", "folder": "gumroad", "urls": [
            "https://gumroad.com", "https://gumroad.com/features", "https://gumroad.com/pricing"
        ], "labels": ["homepage", "features", "pricing"]},
        {"name": "Linear Commerce", "folder": "linear-commerce", "urls": [
            "https://linear.app", "https://linear.app/features", "https://linear.app/pricing"
        ], "labels": ["homepage", "features", "pricing"]},
    ],
    "saas-dashboards": [
        {"name": "Linear", "folder": "linear", "urls": [
            "https://linear.app", "https://linear.app/features", "https://linear.app/method"
        ], "labels": ["homepage", "features", "method"]},
        {"name": "Notion", "folder": "notion", "urls": [
            "https://www.notion.com", "https://www.notion.com/product", "https://www.notion.com/pricing"
        ], "labels": ["homepage", "product", "pricing"]},
        {"name": "Vercel", "folder": "vercel", "urls": [
            "https://vercel.com", "https://vercel.com/features", "https://vercel.com/pricing"
        ], "labels": ["homepage", "features", "pricing"]},
    ],
    "social": [
        {"name": "Threads", "folder": "threads", "urls": [
            "https://www.threads.net", "https://about.instagram.com/threads", "https://about.instagram.com/blog/announcements/threads"
        ], "labels": ["homepage", "about", "announcements"]},
        {"name": "Discord", "folder": "discord", "urls": [
            "https://discord.com", "https://discord.com/nitro", "https://discord.com/safety"
        ], "labels": ["homepage", "nitro", "safety"]},
        {"name": "BeReal", "folder": "bereal", "urls": [
            "https://bereal.com", "https://bereal.com/en", "https://bereal.com/en"
        ], "labels": ["homepage", "landing", "features"]},
    ],
    "marketplace": [
        {"name": "Airbnb", "folder": "airbnb", "urls": [
            "https://www.airbnb.com", "https://www.airbnb.com/host", "https://www.airbnb.com/help"
        ], "labels": ["homepage", "host", "help-center"]},
        {"name": "Etsy", "folder": "etsy", "urls": [
            "https://www.etsy.com", "https://www.etsy.com/sell", "https://www.etsy.com/market/trending"
        ], "labels": ["homepage", "sell", "trending"]},
        {"name": "Fiverr", "folder": "fiverr", "urls": [
            "https://www.fiverr.com", "https://www.fiverr.com/categories", "https://business.fiverr.com"
        ], "labels": ["homepage", "categories", "business"]},
    ],
    "edtech": [
        {"name": "Duolingo", "folder": "duolingo", "urls": [
            "https://www.duolingo.com", "https://www.duolingo.com/courses", "https://www.duolingo.com/efficacy"
        ], "labels": ["homepage", "courses", "efficacy"]},
        {"name": "Coursera", "folder": "coursera", "urls": [
            "https://www.coursera.org", "https://www.coursera.org/courses", "https://www.coursera.org/for-enterprise"
        ], "labels": ["homepage", "courses", "enterprise"]},
        {"name": "Brilliant", "folder": "brilliant", "urls": [
            "https://brilliant.org", "https://brilliant.org/courses", "https://brilliant.org/pricing"
        ], "labels": ["homepage", "courses", "pricing"]},
    ],
    "travel": [
        {"name": "Booking.com", "folder": "booking-com", "urls": [
            "https://www.booking.com", "https://www.booking.com/flights", "https://www.booking.com/attractions"
        ], "labels": ["homepage", "flights", "attractions"]},
        {"name": "Google Flights", "folder": "google-flights", "urls": [
            "https://www.google.com/travel/flights", "https://www.google.com/travel/hotels", "https://www.google.com/travel/explore"
        ], "labels": ["flights", "hotels", "explore"]},
        {"name": "Hopper", "folder": "hopper", "urls": [
            "https://www.hopper.com", "https://www.hopper.com/flights", "https://www.hopper.com/hotels"
        ], "labels": ["homepage", "flights", "hotels"]},
    ],
    "productivity": [
        {"name": "Todoist", "folder": "todoist", "urls": [
            "https://todoist.com", "https://todoist.com/features", "https://todoist.com/pricing"
        ], "labels": ["homepage", "features", "pricing"]},
        {"name": "Arc Browser", "folder": "arc-browser", "urls": [
            "https://arc.net", "https://arc.net/max", "https://resources.arc.net"
        ], "labels": ["homepage", "arc-max", "resources"]},
        {"name": "Raycast", "folder": "raycast", "urls": [
            "https://www.raycast.com", "https://www.raycast.com/pro", "https://www.raycast.com/store"
        ], "labels": ["homepage", "pro", "store"]},
    ],
    "crm": [
        {"name": "HubSpot", "folder": "hubspot", "urls": [
            "https://www.hubspot.com", "https://www.hubspot.com/products/crm", "https://www.hubspot.com/pricing"
        ], "labels": ["homepage", "crm-product", "pricing"]},
        {"name": "Attio", "folder": "attio", "urls": [
            "https://attio.com", "https://attio.com/features", "https://attio.com/pricing"
        ], "labels": ["homepage", "features", "pricing"]},
        {"name": "Folk", "folder": "folk", "urls": [
            "https://www.folk.app", "https://www.folk.app/features", "https://www.folk.app/pricing"
        ], "labels": ["homepage", "features", "pricing"]},
    ],
    "analytics": [
        {"name": "Mixpanel", "folder": "mixpanel", "urls": [
            "https://mixpanel.com", "https://mixpanel.com/reports", "https://mixpanel.com/pricing"
        ], "labels": ["homepage", "reports", "pricing"]},
        {"name": "Amplitude", "folder": "amplitude", "urls": [
            "https://amplitude.com", "https://amplitude.com/analytics", "https://amplitude.com/pricing"
        ], "labels": ["homepage", "analytics", "pricing"]},
        {"name": "PostHog", "folder": "posthog", "urls": [
            "https://posthog.com", "https://posthog.com/product-analytics", "https://posthog.com/pricing"
        ], "labels": ["homepage", "product-analytics", "pricing"]},
    ],
    "developer-tools": [
        {"name": "GitHub", "folder": "github", "urls": [
            "https://github.com", "https://github.com/features", "https://github.com/features/copilot"
        ], "labels": ["homepage", "features", "copilot"]},
        {"name": "Vercel Dashboard", "folder": "vercel-dashboard", "urls": [
            "https://vercel.com", "https://vercel.com/features/infrastructure", "https://vercel.com/integrations"
        ], "labels": ["homepage", "infrastructure", "integrations"]},
        {"name": "Railway", "folder": "railway", "urls": [
            "https://railway.com", "https://railway.com/pricing", "https://docs.railway.com"
        ], "labels": ["homepage", "pricing", "docs"]},
    ],
    "media-streaming": [
        {"name": "Spotify", "folder": "spotify", "urls": [
            "https://www.spotify.com", "https://www.spotify.com/premium", "https://www.spotify.com/wrapped"
        ], "labels": ["homepage", "premium", "wrapped"]},
        {"name": "YouTube Music", "folder": "youtube-music", "urls": [
            "https://music.youtube.com", "https://www.youtube.com/premium", "https://music.youtube.com/explore"
        ], "labels": ["homepage", "premium", "explore"]},
        {"name": "Apple TV", "folder": "apple-tv", "urls": [
            "https://tv.apple.com", "https://www.apple.com/apple-tv-plus", "https://www.apple.com/apple-tv-4k"
        ], "labels": ["homepage", "tv-plus", "tv-4k"]},
    ],
    "food-delivery": [
        {"name": "DoorDash", "folder": "doordash", "urls": [
            "https://www.doordash.com", "https://www.doordash.com/about", "https://www.doordash.com/dashpass"
        ], "labels": ["homepage", "about", "dashpass"]},
        {"name": "Uber Eats", "folder": "uber-eats", "urls": [
            "https://www.ubereats.com", "https://merchants.ubereats.com", "https://www.ubereats.com/near-me"
        ], "labels": ["homepage", "merchants", "near-me"]},
        {"name": "Deliveroo", "folder": "deliveroo", "urls": [
            "https://deliveroo.co.uk", "https://deliveroo.co.uk/plus", "https://restaurants.deliveroo.com"
        ], "labels": ["homepage", "plus", "restaurants"]},
    ],
    "fitness": [
        {"name": "Strava", "folder": "strava", "urls": [
            "https://www.strava.com", "https://www.strava.com/features", "https://www.strava.com/subscribe"
        ], "labels": ["homepage", "features", "subscribe"]},
        {"name": "Peloton", "folder": "peloton", "urls": [
            "https://www.onepeloton.com", "https://www.onepeloton.com/app", "https://www.onepeloton.com/membership"
        ], "labels": ["homepage", "app", "membership"]},
        {"name": "WHOOP", "folder": "whoop", "urls": [
            "https://www.whoop.com", "https://www.whoop.com/us/en/thewhoop", "https://www.whoop.com/us/en/membership"
        ], "labels": ["homepage", "the-whoop", "membership"]},
    ],
}


async def capture_screenshots():
    """Capture all product screenshots."""
    results = {"success": [], "failed": []}

    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        context = await browser.new_context(
            viewport={"width": 1440, "height": 900},
            user_agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        )

        for vertical, products in PRODUCTS.items():
            print(f"\n{'='*60}")
            print(f"Vertical: {vertical}")
            print(f"{'='*60}")

            for product in products:
                product_dir = os.path.join(REFERENCES_DIR, vertical, product["folder"])
                os.makedirs(product_dir, exist_ok=True)

                for i, (url, label) in enumerate(zip(product["urls"], product["labels"])):
                    screenshot_path = os.path.join(product_dir, f"{label}.png")

                    if os.path.exists(screenshot_path):
                        print(f"  [SKIP] {product['name']} - {label} (already exists)")
                        results["success"].append(f"{vertical}/{product['folder']}/{label}")
                        continue

                    try:
                        page = await context.new_page()
                        print(f"  [{vertical}] {product['name']} - {label}: {url}")

                        await page.goto(url, wait_until="domcontentloaded", timeout=30000)
                        await page.wait_for_timeout(3000)  # Wait for animations/lazy loads

                        # Dismiss common popups/banners
                        for selector in [
                            'button:has-text("Accept")',
                            'button:has-text("Got it")',
                            'button:has-text("Close")',
                            '[aria-label="Close"]',
                            'button:has-text("Reject")',
                            'button:has-text("Decline")',
                        ]:
                            try:
                                el = page.locator(selector).first
                                if await el.is_visible(timeout=1000):
                                    await el.click()
                                    await page.wait_for_timeout(500)
                            except:
                                pass

                        await page.screenshot(path=screenshot_path, full_page=False)
                        results["success"].append(f"{vertical}/{product['folder']}/{label}")
                        print(f"    -> Saved: {label}.png")
                        await page.close()

                    except Exception as e:
                        results["failed"].append({
                            "product": f"{vertical}/{product['folder']}/{label}",
                            "url": url,
                            "error": str(e)
                        })
                        print(f"    -> FAILED: {e}")
                        try:
                            await page.close()
                        except:
                            pass

        await browser.close()

    # Print summary
    print(f"\n{'='*60}")
    print(f"SUMMARY")
    print(f"{'='*60}")
    print(f"Success: {len(results['success'])}")
    print(f"Failed: {len(results['failed'])}")
    if results["failed"]:
        print("\nFailed captures:")
        for f in results["failed"]:
            print(f"  - {f['product']}: {f['error'][:80]}")

    # Save results
    results_path = os.path.join(REFERENCES_DIR, "capture-results.json")
    with open(results_path, "w") as f:
        json.dump(results, f, indent=2)
    print(f"\nResults saved to: {results_path}")


if __name__ == "__main__":
    asyncio.run(capture_screenshots())
