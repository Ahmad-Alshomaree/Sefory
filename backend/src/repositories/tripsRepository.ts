import { query } from '../config/database.js';

export interface TripRow {
  id: string;
  passenger_id: string;
  driver_id: string | null;
  car_id: string | null;
  trip_type: 'family' | 'individual';
  departure_city_id: number;
  destination_city_id: number;
  pickup_map_link: string;
  dropoff_map_link: string;
  status: 'requested' | 'accepted' | 'declined' | 'started' | 'completed' | 'cancelled';
  price: string | null;
  requested_at: string;
}

export interface CreateTripRowInput {
  passengerId: string;
  driverId?: string;
  carId?: string;
  tripType: 'family' | 'individual';
  departureCityId: number;
  destinationCityId: number;
  pickupMapLink: string;
  dropoffMapLink: string;
}

export async function insertTrip(input: CreateTripRowInput): Promise<TripRow> {
  const rows = await query<TripRow>(
    `INSERT INTO trips (
      passenger_id,
      driver_id,
      car_id,
      trip_type,
      departure_city_id,
      destination_city_id,
      pickup_map_link,
      dropoff_map_link
    )
    VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
    RETURNING id, passenger_id, driver_id, car_id, trip_type, departure_city_id, destination_city_id, pickup_map_link, dropoff_map_link, status, price, requested_at`,
    [
      input.passengerId,
      input.driverId ?? null,
      input.carId ?? null,
      input.tripType,
      input.departureCityId,
      input.destinationCityId,
      input.pickupMapLink,
      input.dropoffMapLink,
    ],
  );

  return rows[0];
}

export async function fetchTrips(): Promise<TripRow[]> {
  return query<TripRow>(
    'SELECT id, passenger_id, driver_id, car_id, trip_type, departure_city_id, destination_city_id, pickup_map_link, dropoff_map_link, status, price, requested_at FROM trips ORDER BY requested_at DESC',
  );
}
