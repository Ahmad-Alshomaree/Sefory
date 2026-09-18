import { query } from '../config/database.js';

export interface DriverRecord {
  id: string;
  full_name: string;
  surname: string;
  phone_number: string;
  password_hash: string;
  license_number: string;
  license_photo_url: string | null;
  is_verified: boolean;
  cancellation_strikes: number;
  created_at: string;
}

export interface CreateDriverInput {
  fullName: string;
  surname: string;
  phoneNumber: string;
  passwordHash: string;
  licenseNumber: string;
  licensePhotoUrl?: string | null;
}

export async function findDriverByPhoneNumber(phoneNumber: string): Promise<DriverRecord | null> {
  const rows = await query<DriverRecord>(
    'SELECT id, full_name, surname, phone_number, password_hash, license_number, license_photo_url, is_verified, cancellation_strikes, created_at FROM drivers WHERE phone_number = $1 LIMIT 1',
    [phoneNumber],
  );

  return rows[0] ?? null;
}

export async function findDriverById(id: string): Promise<DriverRecord | null> {
  const rows = await query<DriverRecord>(
    'SELECT id, full_name, surname, phone_number, password_hash, license_number, license_photo_url, is_verified, cancellation_strikes, created_at FROM drivers WHERE id = $1 LIMIT 1',
    [id],
  );

  return rows[0] ?? null;
}

export async function createDriver(input: CreateDriverInput): Promise<DriverRecord> {
  const rows = await query<DriverRecord>(
    `INSERT INTO drivers (full_name, surname, phone_number, password_hash, license_number, license_photo_url)
     VALUES ($1, $2, $3, $4, $5, $6)
     RETURNING id, full_name, surname, phone_number, password_hash, license_number, license_photo_url, is_verified, cancellation_strikes, created_at`,
    [
      input.fullName,
      input.surname,
      input.phoneNumber,
      input.passwordHash,
      input.licenseNumber,
      input.licensePhotoUrl ?? null,
    ],
  );

  return rows[0];
}
