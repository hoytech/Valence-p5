use common::sense;

use Valence;


my $v = Valence->new;

my $app = $v->require('app');

my $browser_window = $v->require('browser-window');
my $main_window;

$app->on(ready => sub {
  $main_window = $browser_window->new({ width => 1000, height => 600, show => \1 });
 
  $main_window->loadUrl("http://google.ca");

  $main_window->getPosition->(sub {
    my $res = shift;
    say "POSITION: x = $res->[0], y => $res->[1]";
  });

  $main_window->attr('id')->(sub {
    say "Window ID = $_[0]";
  });

  $main_window->on('blur', sub { say "BLURRED" });
  $main_window->on('focus', sub { say "FOCUSED" });
});

$v->run;




__END__

my $v = Valence->new;

$v->send({ save => 1, cmd => "call", method => "require", args => ["app"]});
$v->send({ save => 2, cmd => "call", method => "require", args => ["browser-window"]});

$v->send({ cmd => "call", obj => 1, "method" => "on", args => ["ready", undef], args_cb => [[1, 100]] });
## >> { cmd => "cb", id => 100, args => [] }

#$v->send({ save => 3, cmd => "call", method => "new", obj => 2, args => [{width => 800, height => 600, show => \1}]});

$v->run;




{ cmd => "get", cb => 3, obj => 1 }
=> { cmd => "cb", cb => 3, args => [] }
