import { query } from '../config/database.js';

export interface AllowedCityRecord {
  driver_id: string;
  city_id: number;
}

export async function replaceDriverCities(driverId: string, cityIds: number[]): Promise<void> {
  await query('DELETE FROM driver_cities WHERE driver_id = $1', [driverId]);

  for (const cityId of cityIds) {
    await query('INSERT INTO driver_cities (driver_id, city_id) VALUES ($1, $2)', [driverId, cityId]);
  }
}

export async function listDriverCityIds(driverId: string): Promise<number[]> {
  const rows = await query<{ city_id: number }>(
    'SELECT city_id FROM driver_cities WHERE driver_id = $1 ORDER BY city_id ASC',
    [driverId],
  );

  return rows.map((row) => row.city_id);
}
