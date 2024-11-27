const { readFileSync } = require('fs');

const main = () => {
  const lines = readFileSync(`${__dirname}/../docker-minecraft.log`, 'utf-8').split('\n');
  const joins = lines
    .filter(p => p.includes('joined the game'))
    .map(p => p.split('[93m')[1].split('joined')[0].trim());
  const set = new Set(joins);
  console.log(set);
};

main();
