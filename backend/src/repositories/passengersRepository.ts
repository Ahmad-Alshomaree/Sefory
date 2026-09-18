import { query } from '../config/database.js';

export interface PassengerRecord {
  id: string;
  full_name: string;
  phone_number: string;
  password_hash: string;
  created_at: string;
}

export interface CreatePassengerInput {
  fullName: string;
  phoneNumber: string;
  passwordHash: string;
}

export async function findPassengerByPhoneNumber(phoneNumber: string): Promise<PassengerRecord | null> {
  const rows = await query<PassengerRecord>(
    'SELECT id, full_name, phone_number, password_hash, created_at FROM passengers WHERE phone_number = $1 LIMIT 1',
    [phoneNumber],
  );

  return rows[0] ?? null;
}

export async function findPassengerById(id: string): Promise<PassengerRecord | null> {
  const rows = await query<PassengerRecord>(
    'SELECT id, full_name, phone_number, password_hash, created_at FROM passengers WHERE id = $1 LIMIT 1',
    [id],
  );

  return rows[0] ?? null;
}

export async function createPassenger(input: CreatePassengerInput): Promise<PassengerRecord> {
  const rows = await query<PassengerRecord>(
    `INSERT INTO passengers (full_name, phone_number, password_hash)
     VALUES ($1, $2, $3)
     RETURNING id, full_name, phone_number, password_hash, created_at`,
    [input.fullName, input.phoneNumber, input.passwordHash],
  );

  return rows[0];
}
