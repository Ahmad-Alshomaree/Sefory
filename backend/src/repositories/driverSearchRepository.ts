import { query } from '../config/database.js';

export interface DriverSearchResultRow {
  driver_id: string;
  full_name: string;
  surname: string;
  phone_number: string;
  is_verified: boolean;
  cancellation_strikes: number;
  car_id: string;
  model: string;
  name: string | null;
  plate_number: string;
  color: string | null;
  year: number | null;
  photo_url: string | null;
  price: string | null;
}

export async function searchDriversByRoute(departureCityId: number, destinationCityId: number): Promise<DriverSearchResultRow[]> {
  return query<DriverSearchResultRow>(
    `SELECT
      d.id AS driver_id,
      d.full_name,
      d.surname,
      d.phone_number,
      d.is_verified,
      d.cancellation_strikes,
      c.id AS car_id,
      c.model,
      c.name,
      c.plate_number,
      c.color,
      c.year,
      c.photo_url,
      c.price
    FROM drivers d
    JOIN cars c ON c.driver_id = d.id AND c.is_active = true
    WHERE EXISTS (
      SELECT 1 FROM driver_cities dc WHERE dc.driver_id = d.id AND dc.city_id = $1
    )
    AND EXISTS (
      SELECT 1 FROM driver_cities dc WHERE dc.driver_id = d.id AND dc.city_id = $2
    )
    ORDER BY d.is_verified DESC, d.cancellation_strikes ASC, c.created_at DESC`,
    [departureCityId, destinationCityId],
  );
}
