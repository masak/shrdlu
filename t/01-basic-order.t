use v6;
use Test;

use Shrdlu;

my $machine = Shrdlu.new;

$machine.tell('Pick up a big red block.');
is_deeply $machine.reply, ['OK.'], 'unambiguous instruction';

$machine.tell('Grasp the pyramid.');
is_deeply $machine.reply, [q[I don't understand which pyramid you mean.]], # '
          'ambiguous instruction';
