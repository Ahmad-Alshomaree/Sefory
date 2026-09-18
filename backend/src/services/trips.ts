import {
  acceptTrip,
  fetchTripsForDriver,
  fetchTripsForPassenger,
  findTripById,
  updateTripStatus,
} from '../repositories/tripActionsRepository.js';
import { insertTrip } from '../repositories/tripsRepository.js';

export interface CreateTripRequest {
  passengerId: string;
  driverId?: string;
  carId?: string;
  tripType: 'family' | 'individual';
  departureCityId: number;
  destinationCityId: number;
  pickupMapLink: string;
  dropoffMapLink: string;
}

export interface TripRecord {
  id: string;
  passengerId: string;
  driverId: string | null;
  carId: string | null;
  tripType: 'family' | 'individual';
  departureCityId: number;
  destinationCityId: number;
  pickupMapLink: string;
  dropoffMapLink: string;
  status: 'requested' | 'accepted' | 'declined' | 'started' | 'completed' | 'cancelled';
  price: string | null;
  requestedAt: string;
  acceptedAt: string | null;
  startedAt: string | null;
  completedAt: string | null;
  cancelledAt: string | null;
}

type TripRow = NonNullable<Awaited<ReturnType<typeof findTripById>>>;

function mapTripRow(row: TripRow): TripRecord {
  return {
    id: row.id,
    passengerId: row.passenger_id,
    driverId: row.driver_id,
    carId: row.car_id,
    tripType: row.trip_type,
    departureCityId: row.departure_city_id,
    destinationCityId: row.destination_city_id,
    pickupMapLink: row.pickup_map_link,
    dropoffMapLink: row.dropoff_map_link,
    status: row.status,
    price: row.price,
    requestedAt: row.requested_at,
    acceptedAt: row.accepted_at,
    startedAt: row.started_at,
    completedAt: row.completed_at,
    cancelledAt: row.cancelled_at,
  };
}

export async function createTrip(request: CreateTripRequest): Promise<TripRecord> {
  const trip = await insertTrip(request);
  const fullTrip = await findTripById(trip.id);

  if (!fullTrip) {
    throw new Error('Created trip could not be loaded');
  }

  return mapTripRow(fullTrip);
}

export async function listTripsForUser(userId: string, role: 'passenger' | 'driver'): Promise<TripRecord[]> {
  const trips = role === 'driver' ? await fetchTripsForDriver(userId) : await fetchTripsForPassenger(userId);
  return trips.map(mapTripRow);
}

export async function acceptTripRequest(tripId: string, driverId: string, carId: string, price: number): Promise<TripRecord | null> {
  const trip = await acceptTrip(tripId, driverId, carId, price);
  return trip ? mapTripRow(trip) : null;
}

export async function transitionTrip(tripId: string, status: 'declined' | 'started' | 'completed' | 'cancelled'): Promise<TripRecord | null> {
  const trip = await updateTripStatus(tripId, status);
  return trip ? mapTripRow(trip) : null;
}
