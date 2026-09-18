import { Router } from 'express';

import { authRouter } from './auth.js';
import { citiesRouter } from './cities.js';
import { driversRouter } from './drivers.js';
import { tripsRouter } from './trips.js';

export const v1Router = Router();

v1Router.use('/auth', authRouter);
v1Router.use('/cities', citiesRouter);
v1Router.use('/drivers', driversRouter);
v1Router.use('/trips', tripsRouter);
