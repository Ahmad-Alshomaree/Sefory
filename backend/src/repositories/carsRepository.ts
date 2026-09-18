import { query } from '../config/database.js';

export interface CarRecord {
  id: string;
  driver_id: string;
  model: string;
  name: string | null;
  plate_number: string;
  color: string | null;
  year: number | null;
  photo_url: string | null;
  price: string | null;
  is_active: boolean;
  created_at: string;
}

export interface CreateCarInput {
  driverId: string;
  model: string;
  name?: string | null;
  plateNumber: string;
  color?: string | null;
  year?: number | null;
  photoUrl?: string | null;
  price?: number | null;
}

export async function createCar(input: CreateCarInput): Promise<CarRecord> {
  const rows = await query<CarRecord>(
    `INSERT INTO cars (
      driver_id,
      model,
      name,
      plate_number,
      color,
      year,
      photo_url,
      price
    )
    VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
    RETURNING id, driver_id, model, name, plate_number, color, year, photo_url, price, is_active, created_at`,
    [
      input.driverId,
      input.model,
      input.name ?? null,
      input.plateNumber,
      input.color ?? null,
      input.year ?? null,
      input.photoUrl ?? null,
      input.price ?? null,
    ],
  );

  return rows[0];
}

export async function listCarsByDriver(driverId: string): Promise<CarRecord[]> {
  return query<CarRecord>(
    'SELECT id, driver_id, model, name, plate_number, color, year, photo_url, price, is_active, created_at FROM cars WHERE driver_id = $1 ORDER BY created_at DESC',
    [driverId],
  );
}

export async function findActiveCarsByDriver(driverId: string): Promise<CarRecord[]> {
  return query<CarRecord>(
    'SELECT id, driver_id, model, name, plate_number, color, year, photo_url, price, is_active, created_at FROM cars WHERE driver_id = $1 AND is_active = true ORDER BY created_at DESC',
    [driverId],
  );
}

export async function findCarById(carId: string): Promise<CarRecord | null> {
  const rows = await query<CarRecord>(
    'SELECT id, driver_id, model, name, plate_number, color, year, photo_url, price, is_active, created_at FROM cars WHERE id = $1 LIMIT 1',
    [carId],
  );

  return rows[0] ?? null;
}
