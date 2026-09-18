import { createDriver, findDriverByPhoneNumber } from '../repositories/driversRepository.js';
import { createPassenger, findPassengerByPhoneNumber } from '../repositories/passengersRepository.js';
import { comparePassword, hashPassword } from './passwords.js';
import { signAccessToken } from './jwt.js';

export interface PassengerAuthPayload {
  fullName: string;
  phoneNumber: string;
  password: string;
}

export interface DriverAuthPayload {
  fullName: string;
  surname: string;
  phoneNumber: string;
  password: string;
  licenseNumber: string;
  licensePhotoUrl?: string | null;
}

export interface LoginPayload {
  phoneNumber: string;
  password: string;
}

function buildPassengerSession(passenger: { id: string; full_name: string; phone_number: string }) {
  return {
    user: {
      id: passenger.id,
      role: 'passenger' as const,
      fullName: passenger.full_name,
      phoneNumber: passenger.phone_number,
    },
    token: signAccessToken({ sub: passenger.id, role: 'passenger' }),
  };
}

function buildDriverSession(driver: { id: string; full_name: string; surname: string; phone_number: string }) {
  return {
    user: {
      id: driver.id,
      role: 'driver' as const,
      fullName: driver.full_name,
      surname: driver.surname,
      phoneNumber: driver.phone_number,
    },
    token: signAccessToken({ sub: driver.id, role: 'driver' }),
  };
}

export async function registerPassenger(payload: PassengerAuthPayload) {
  const existing = await findPassengerByPhoneNumber(payload.phoneNumber);

  if (existing) {
    throw new Error('Passenger with this phone number already exists');
  }

  const passwordHash = await hashPassword(payload.password);
  const passenger = await createPassenger({
    fullName: payload.fullName,
    phoneNumber: payload.phoneNumber,
    passwordHash,
  });

  return buildPassengerSession(passenger);
}

export async function loginPassenger(payload: LoginPayload) {
  const passenger = await findPassengerByPhoneNumber(payload.phoneNumber);

  if (!passenger) {
    throw new Error('Invalid passenger credentials');
  }

  const validPassword = await comparePassword(payload.password, passenger.password_hash);

  if (!validPassword) {
    throw new Error('Invalid passenger credentials');
  }

  return buildPassengerSession(passenger);
}

export async function registerDriver(payload: DriverAuthPayload) {
  const existing = await findDriverByPhoneNumber(payload.phoneNumber);

  if (existing) {
    throw new Error('Driver with this phone number already exists');
  }

  const passwordHash = await hashPassword(payload.password);
  const driver = await createDriver({
    fullName: payload.fullName,
    surname: payload.surname,
    phoneNumber: payload.phoneNumber,
    passwordHash,
    licenseNumber: payload.licenseNumber,
    licensePhotoUrl: payload.licensePhotoUrl ?? null,
  });

  return buildDriverSession(driver);
}

export async function loginDriver(payload: LoginPayload) {
  const driver = await findDriverByPhoneNumber(payload.phoneNumber);

  if (!driver) {
    throw new Error('Invalid driver credentials');
  }

  const validPassword = await comparePassword(payload.password, driver.password_hash);

  if (!validPassword) {
    throw new Error('Invalid driver credentials');
  }

  return buildDriverSession(driver);
}
