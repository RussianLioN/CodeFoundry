// ═════════════════════════════════════════════════════════════════════════════
// E2E Tests - Authentication (Playwright)
// ═══════════════════════════════════════════════════════════════════════════════

import { test, expect } from '@playwright/test'

test.describe('Authentication Flow', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/')
  })

  test('user can register', async ({ page }) => {
    // Navigate to register page
    await page.click('text=Sign up')
    await expect(page).toHaveURL(/\/register/)

    // Fill registration form
    await page.fill('[name="email"]', 'test@example.com')
    await page.fill('[name="username"]', 'testuser')
    await page.fill('[name="password"]', 'Password123!')
    await page.fill('[name="confirmPassword"]', 'Password123!')

    // Submit form
    await page.click('button[type="submit"]')

    // Should redirect to dashboard
    await expect(page).toHaveURL(/\/dashboard/)
    await expect(page.locator('h1')).toContainText('Dashboard')
  })

  test('user can login', async ({ page }) => {
    // Navigate to login page
    await page.click('text=Log in')
    await expect(page).toHaveURL(/\/login/)

    // Fill login form
    await page.fill('[name="email"]', 'test@example.com')
    await page.fill('[name="password"]', 'Password123!')

    // Submit form
    await page.click('button[type="submit"]')

    // Should redirect to dashboard
    await expect(page).toHaveURL(/\/dashboard/)
    await expect(page.locator('[data-testid="user-menu"]')).toBeVisible()
  })

  test('shows validation errors for invalid credentials', async ({ page }) => {
    await page.goto('/login')

    // Fill with invalid credentials
    await page.fill('[name="email"]', 'invalid@example.com')
    await page.fill('[name="password"]', 'wrongpassword')

    // Submit form
    await page.click('button[type="submit"]')

    // Should show error message
    await expect(page.locator('text=Invalid credentials')).toBeVisible()
  })

  test('redirects unauthenticated users to login', async ({ page }) => {
    // Try to access protected route
    await page.goto('/dashboard')

    // Should redirect to login
    await expect(page).toHaveURL(/\/login/)
  })

  test('user can logout', async ({ page, context }) => {
    // First login
    await page.goto('/login')
    await page.fill('[name="email"]', 'test@example.com')
    await page.fill('[name="password"]', 'Password123!')
    await page.click('button[type="submit"]')

    // Wait for navigation to dashboard
    await expect(page).toHaveURL(/\/dashboard/)

    // Click logout
    await page.click('[data-testid="user-menu"]')
    await page.click('text=Log out')

    // Should redirect to home and clear cookies
    await expect(page).toHaveURL('/')
    const cookies = await context.cookies()
    expect(cookies.filter(c => c.name === 'token')).toHaveLength(0)
  })
})

test.describe('Password Reset', () => {
  test('user can request password reset', async ({ page }) => {
    await page.goto('/login')
    await page.click('text=Forgot password?')

    await expect(page).toHaveURL(/\/forgot-password/)

    await page.fill('[name="email"]', 'test@example.com')
    await page.click('button[type="submit"]')

    await expect(page.locator('text=Check your email')).toBeVisible()
  })
})
