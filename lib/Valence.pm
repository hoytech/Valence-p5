package Valence;

use common::sense;

use AnyEvent;
use AnyEvent::Util;
use AnyEvent::Handle;
use Callback::Frame;
use JSON::XS;
use File::Spec;

use Valence::Object;


my $electron_dir = '/home/doug/tp/electron';
my $valence_dir = '/home/doug/valence';


sub new {
  my ($class, %args) = @_;

  my $self = {
    next_object_id => 1,
    object_map => {},

    next_callback_id => 1,
    callback_map => {},
  };

  bless $self, $class;

  my ($fh1, $fh2) = portable_socketpair();

  $self->{cv} = run_cmd [ "$electron_dir/electron", $valence_dir ],
                        close_all => 1,
                        '>' => $fh2,
                        '<' => $fh2,
                        '2>' => $ENV{VALENCE_DEBUG} >= 2 ? \*STDERR : File::Spec->devnull(),
                        '$$' => \$self->{pid};

  close $fh2;

  $self->{fh} = $fh1;

  $self->{hdl} = AnyEvent::Handle->new(fh => $self->{fh});

  my $line_handler; $line_handler = sub {
    my ($hdl, $line) = @_;

    my $msg = eval { decode_json($line) };

    if ($@) {
      warn "error decoding JSON from electron: $@: $line";
    } else {
      debug(1, sub { "<<<<<<<<<<<<<<<<< Message from electron" }, $msg, 1);

      $self->_handle_msg($msg);
    }

    $self->{hdl}->push_read(line => $line_handler);
  };

  $self->{hdl}->push_read(line => $line_handler);

  return $self;
}



sub _handle_msg {
  my ($self, $msg) = @_;

  if ($msg->{cmd} eq 'cb') {
    $self->{callback_map}->{$msg->{cb}}->(@{ $msg->{args} });
  } else {
    warn "unknown cmd: '$msg->{cmd}'";
  }
}


sub run {
  my ($self) = @_;

  $self->{cv} = AE::cv;

  $self->{cv}->recv;
}




sub _send {
  my ($self, $msg) = @_;

  debug(1, sub { "Sending to valence >>>>>>>>>>>>>>>>>" }, $msg);

  $self->{hdl}->push_write(json => $msg);

  $self->{hdl}->push_write("\n");
}


sub _call_method {
  my ($self, $msg) = @_;

  ## Manipulate arguments

  for (my $i=0; $i < @{ $msg->{args} }; $i++) {
    if (ref $msg->{args}->[$i] eq 'CODE') {
      my $callback_id = $self->{next_callback_id}++;

      push @{ $msg->{args_cb} }, [$i, $callback_id];

      $self->{callback_map}->{$callback_id} = $msg->{args}->[$i];

      $msg->{args}->[$i] = undef;
    }
  }

  ## Send msg

  $msg->{cmd} = 'call';

  my $obj = Valence::Object->_new(valence => $self);

  $msg->{save} = $obj->{id};

  $self->_send($msg);

  return $obj;
}


sub _get_attr {
  my ($self, $msg) = @_;

  ## Send msg

  $msg->{cmd} = 'attr';

  my $obj = Valence::Object->_new(valence => $self);

  $msg->{save} = $obj->{id};

  $self->_send($msg);

  return $obj;
}


sub require {
  my ($self) = shift;

  return $self->_call_method({ method => 'require', args => \@_, });
}




my $pretty_js_ctx;

sub debug {
  my ($level, $msg_cb, $to_dump, $indent) = @_;

  return if $level > $ENV{VALENCE_DEBUG};

  $pretty_js_ctx ||=  JSON::XS->new->pretty->canonical;

  my $out = "\n" . $msg_cb->() . "\n";

  $out .= $pretty_js_ctx->encode($to_dump) . "\n" if $to_dump;

  $out =~ s/\n/\n                /g if $indent;

  print STDERR $out;
}



sub DESTROY {
  my ($self) = @_;

  kill 'KILL', $self->{pid};
}


1;
