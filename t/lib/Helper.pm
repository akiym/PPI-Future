package Helper;

use strict;
use warnings;
use Exporter ();

our $VERSION = '1.236';

our @ISA = "Exporter";
our @EXPORT_OK = qw( check_with );

sub check_with {
    my ( $code, $checker ) = @_;
    my $Document = PPI::Future::Document->new( \$code );
    is( PPI::Future::Document->errstr, undef ) if PPI::Future::Document->errstr;
    local $_ = $Document;
    $checker->();
}

1;
