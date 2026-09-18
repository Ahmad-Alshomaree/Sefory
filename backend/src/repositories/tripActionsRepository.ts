import { query } from '../config/database.js';

export interface TripActionRow {
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
  accepted_at: string | null;
  started_at: string | null;
  completed_at: string | null;
  cancelled_at: string | null;
}

export async function findTripById(tripId: string): Promise<TripActionRow | null> {
  const rows = await query<TripActionRow>(
    `SELECT id, passenger_id, driver_id, car_id, trip_type, departure_city_id, destination_city_id, pickup_map_link, dropoff_map_link, status, price, requested_at, accepted_at, started_at, completed_at, cancelled_at
     FROM trips WHERE id = $1 LIMIT 1`,
    [tripId],
  );

  return rows[0] ?? null;
}

export async function fetchTripsForPassenger(passengerId: string): Promise<TripActionRow[]> {
  return query<TripActionRow>(
    `SELECT id, passenger_id, driver_id, car_id, trip_type, departure_city_id, destination_city_id, pickup_map_link, dropoff_map_link, status, price, requested_at, accepted_at, started_at, completed_at, cancelled_at
     FROM trips WHERE passenger_id = $1 ORDER BY requested_at DESC`,
    [passengerId],
  );
}

export async function fetchTripsForDriver(driverId: string): Promise<TripActionRow[]> {
  return query<TripActionRow>(
    `SELECT id, passenger_id, driver_id, car_id, trip_type, departure_city_id, destination_city_id, pickup_map_link, dropoff_map_link, status, price, requested_at, accepted_at, started_at, completed_at, cancelled_at
     FROM trips WHERE driver_id = $1 ORDER BY requested_at DESC`,
    [driverId],
  );
}

export async function acceptTrip(tripId: string, driverId: string, carId: string, price: number): Promise<TripActionRow | null> {
  const rows = await query<TripActionRow>(
    `UPDATE trips
     SET driver_id = $2,
         car_id = $3,
         price = $4,
         status = 'accepted',
         accepted_at = now()
     WHERE id = $1 AND status = 'requested'
     RETURNING id, passenger_id, driver_id, car_id, trip_type, departure_city_id, destination_city_id, pickup_map_link, dropoff_map_link, status, price, requested_at, accepted_at, started_at, completed_at, cancelled_at`,
    [tripId, driverId, carId, price],
  );

  return rows[0] ?? null;
}

export async function updateTripStatus(tripId: string, status: 'declined' | 'started' | 'completed' | 'cancelled'): Promise<TripActionRow | null> {
  const column = status === 'started' ? 'started_at' : status === 'completed' ? 'completed_at' : 'cancelled_at';
  const rows = await query<TripActionRow>(
    `UPDATE trips
     SET status = $2,
         ${column} = now()
     WHERE id = $1
     RETURNING id, passenger_id, driver_id, car_id, trip_type, departure_city_id, destination_city_id, pickup_map_link, dropoff_map_link, status, price, requested_at, accepted_at, started_at, completed_at, cancelled_at`,
    [tripId, status],
  );

  return rows[0] ?? null;
}
