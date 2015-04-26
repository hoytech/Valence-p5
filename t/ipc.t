use Test::More tests => 2;

use common::sense;

use AnyEvent;
use Valence;
use Cwd;

my $cv = AE::cv;

my $v = Valence->new;

my $app = $v->require('app');
my $browser_window = $v->require('browser-window');
my $ipc = $v->require('ipc');

my $main_window;

$app->on(ready => sub {
  $main_window = $browser_window->new({ width => 1000, height => 600, show => \1, });
  my $web_contents = $main_window->attr('webContents');

  $ipc->on('ready' => sub {
    ok(1, 'got ready');

    $web_contents->send(ping => "HELLO");

    $ipc->on('pong' => sub {
      my ($event, $message) = @_;

      is($message, "HELLOHELLO", "got pong");

      $cv->send;
    });
  });

  $main_window->loadUrl('file://' . getcwd() . '/t/static/remote.html');

  $main_window->openDevTools;
});

$cv->recv;
