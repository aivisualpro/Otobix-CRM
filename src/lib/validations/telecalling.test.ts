import { describe, it, expect } from 'vitest';
import { telecallingSchema } from '@/lib/validations/telecalling';

describe('Telecalling Schema Validation', () => {
  it('should validate a correct payload', () => {
    const validData = {
      customerName: 'John Doe',
      customerContactNumber: '1234567890',
      emailAddress: 'john@example.com',
      priority: 'High',
    };

    const result = telecallingSchema.safeParse(validData);
    expect(result.success).toBe(true);
  });

  it('should fail if required fields are missing', () => {
    const invalidData = {
      priority: 'High',
      // missing customerName
    };

    const result = telecallingSchema.safeParse(invalidData);
    expect(result.success).toBe(false);
    if (!result.success) {
      expect(result.error.flatten().fieldErrors.customerName).toBeDefined();
    }
  });

  it('should invalidate incorrect email format', () => {
    const invalidData = {
      customerName: 'Jane Doe',
      emailAddress: 'not-an-email',
    };

    const result = telecallingSchema.safeParse(invalidData);
    expect(result.success).toBe(false);
  });
});
