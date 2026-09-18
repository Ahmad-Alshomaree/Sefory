import { createCar, listCarsByDriver } from '../repositories/carsRepository.js';
import { listDriverCityIds, replaceDriverCities } from '../repositories/driverCitiesRepository.js';
import { findDriverById } from '../repositories/driversRepository.js';
import { searchDriversByRoute } from '../repositories/driverSearchRepository.js';

export interface CreateCarPayload {
  driverId: string;
  model: string;
  name?: string | null;
  plateNumber: string;
  color?: string | null;
  year?: number | null;
  photoUrl?: string | null;
  price?: number | null;
}

export interface SetDriverCitiesPayload {
  driverId: string;
  cityIds: number[];
}

export async function addDriverCar(payload: CreateCarPayload) {
  return createCar(payload);
}

export async function setDriverAllowedCities(payload: SetDriverCitiesPayload) {
  await replaceDriverCities(payload.driverId, payload.cityIds);
  return listDriverCityIds(payload.driverId);
}

export interface DriverSearchResult {
  driverId: string;
  fullName: string;
  surname: string;
  phoneNumber: string;
  isVerified: boolean;
  cancellationStrikes: number;
  carId: string;
  model: string;
  name: string | null;
  plateNumber: string;
  color: string | null;
  year: number | null;
  photoUrl: string | null;
  price: string | null;
}

export async function getDriverProfile(driverId: string) {
  const driver = await findDriverById(driverId);

  if (!driver) {
    return null;
  }

  const cars = await listCarsByDriver(driverId);
  const cityIds = await listDriverCityIds(driverId);

  return {
    driver,
    cars,
    cityIds,
  };
}

export async function searchDrivers(departureCityId: number, destinationCityId: number) {
  const drivers = await searchDriversByRoute(departureCityId, destinationCityId);

  return drivers.map<DriverSearchResult>((driver) => ({
    driverId: driver.driver_id,
    fullName: driver.full_name,
    surname: driver.surname,
    phoneNumber: driver.phone_number,
    isVerified: driver.is_verified,
    cancellationStrikes: driver.cancellation_strikes,
    carId: driver.car_id,
    model: driver.model,
    name: driver.name,
    plateNumber: driver.plate_number,
    color: driver.color,
    year: driver.year,
    photoUrl: driver.photo_url,
    price: driver.price,
  }));
}
