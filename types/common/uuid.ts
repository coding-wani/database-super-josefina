// Branded type for UUID strings to provide better type safety
// This ensures UUIDs can't be accidentally mixed with regular strings
export type UUID = string & { readonly __brand: unique symbol };

// Type guard to check if a string is a valid UUID format
export function isUUID(value: string): value is UUID {
  const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
  return uuidRegex.test(value);
}

// Helper function to create a UUID type from a string (with validation)
export function toUUID(value: string): UUID {
  if (!isUUID(value)) {
    throw new Error(`Invalid UUID format: ${value}`);
  }
  return value as UUID;
}

// Helper function to create a UUID type from a string (without validation - use carefully)
export function asUUID(value: string): UUID {
  return value as UUID;
}