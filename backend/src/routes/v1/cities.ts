import { Router } from 'express';

import { listCities } from '../../services/cities.js';

export const citiesRouter = Router();

citiesRouter.get('/', (_request, response) => {
  response.json({
    success: true,
    data: listCities(),
  });
});
