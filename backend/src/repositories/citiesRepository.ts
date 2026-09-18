import { query } from '../config/database.js';

export interface CityRecord {
  id: number;
  name: string;
}

export async function listCities(): Promise<CityRecord[]> {
  return query<CityRecord>('SELECT id, name FROM cities ORDER BY name ASC');
}
