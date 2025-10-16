import asyncio
from playwright.async_api import async_playwright

AUTH = 'brd-customer-hl_482339a5-zone-scraping222_111:484fl5v89aaf'
SBR_WS_CDP = f'wss://{AUTH}@brd.superproxy.io:9222'

async def run(pw):
    print('Connecting to Scraping Browser...')
    browser = await pw.chromium.connect_over_cdp(SBR_WS_CDP)
    try:
        page = await browser.new_page()
        print('Connected! Navigating to webpage')
        await page.goto('https://www.example.com')
        await page.screenshot(path="page.png", full_page=True)
        print("Screenshot saved as 'page.png'")
        html = await page.content()
        print(html)
    finally:
        await browser.close()

async def main():
    async with async_playwright() as playwright:
        await run(playwright)

if __name__ == '__main__':
    asyncio.run(main())