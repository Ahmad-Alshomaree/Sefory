export interface City {
  id: number;
  name: string;
}

const cities: City[] = [
  { id: 1, name: 'Baghdad' },
  { id: 2, name: 'Basra' },
  { id: 3, name: 'Mosul' },
  { id: 4, name: 'Erbil' },
  { id: 5, name: 'Najaf' },
  { id: 6, name: 'Karbala' },
  { id: 7, name: 'Sulaymaniyah' },
];

export function listCities(): City[] {
  return cities;
}
