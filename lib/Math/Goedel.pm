package Math::Goedel;

use warnings;
use strict;

use Exporter qw/import/;

our @EXPORT_OK = qw/goedel/;

use Math::Prime::XS qw/is_prime/;
use List::Util qw/reduce max/;
use List::MoreUtils qw/pairwise/;
use Carp;

=head1 NAME

Math::Goedel - Fundamental Goedel number calculator

=cut

our $VERSION = '0.03';

=head1 SYNOPSIS

  use Math::Goedel qw/goedel/;

  goedel(9);  # 512 (2**9)
  goedel(81); # 768 (2**8 * 3**1)
  goedel(230);# 108 (2**2 * 3**3 * 5**0)

  Math::Goedel::enc(9); # same as goedel(9)

  goedel(9, offset => 1); # 1024 (2**(9+1))
  goedel(81, reverse => 1); # 13112 (2**1 * 3**8)

=head1 DESCRIPTION

Goedel number is calculated by following Goedel's encoding theorem

  enc(X0X1X2...Xn) = P0**X0 * P1**X1 * P2**X2 * ..... * Pn**Xn

I<Xk> is a I<k> th digit (from left hand) of input number.

I<Pk> is a I<k> th prime number.

=head1 EXPORT

  @EXPORT_OK => qw/goedel/

=head1 FUNCTIONS

=head2 goedel($n, %opts)

calculate goedel number for I<n>

=head3 %opts

=head4 offset => $i

According to fundamental theorem, goedel numbers are not unique.

  goedel(23) == goedel(230); # 2**2 * 3**3 ( * 5**0 ) == 108

To make it unique, you can specify I<offset> for I<Xk>

  enc(X0X1X2...Xn) = P0**(X0 +i) * P1**(X1 +i) * P2**(X2 +i) * ..... * Pn**(Xn +i)

so, 

  goedel(23, offset => 1);  # 2**(2+1) * 3**(3+1) == 648
  goedel(230, offset => 1); # 2**(2+1) * 3**(3+1) * 5**(0+1) == 3240

=head4 reverse => 0|1

This option is for same purpose as offset option.

If reverse is set to 1, apply I<Xk> in reverse order,

  enc(X0X1X2...Xn) = P0**Xn * P1**Xn-1 * P2**Xn-2 * ..... * Pn**X0

so,

  goedel(23,  reverse => 1); # 2**3 * 3**2 == 72
  goedel(230, reverse => 1); # 2**0 * 3**3 * 5**2 == 675

=cut

#sub _pow
#{
#  $_[0]**$_[1];
#}
#memoize('_pow', NORMALIZER => sub {join ':', @_}, LIST_CACHE=>q/FAULT/);

my %_pow_cache = ();
my $_next_prime = sub
{
  my ($m, $offset) = @_;
  ++$m;
  while ( 1 ) {
    last if is_prime($m);
  }
  continue {
    ++$m;
  }
  $m => [map { $m ** ($_+$offset) } 0 .. 9];
};

sub goedel {
  my $n_ = shift;
  my %opts = (
    q/offset/ => 0,
    q/reverse/ => 0,
    @_ );
  
  my $n = -1;
  croak "n should be a non-negative integer"
  if ( $n_ ne ($n = 0 + sprintf '%ld', $n_) || $n_ < 0);

  my $offset = -1;
  croak "offset should be a non-negative integer"
  if ( $opts{q/offset/} ne ($offset = 0 + sprintf('%ld', $opts{q/offset/})) ||
       $offset < 0);


  my $nlen = length($n);

  $_pow_cache{$offset} = {} if !exists $_pow_cache{$offset};
  my $pow_cache_ = $_pow_cache{$offset};

  while ( scalar(keys %$pow_cache_) < $nlen ) {
    my @cache_ = $_next_prime->(
      (%$pow_cache_) ? (max keys %$pow_cache_) : 1,
      $offset);
    $pow_cache_->{$cache_[0]} = $cache_[1];
  }

  my @primes_ = (sort keys %$pow_cache_)[0 .. $nlen-1];
  my @digits_ = split //, $n;
  @digits_ = reverse @digits_ if ($opts{q/reverse/});

  reduce { $a * $b }
  pairwise { $pow_cache_->{$a}[$b] }
  @primes_, @digits_;
}

=head2 enc($n)

synonym for goedel($n). but it won't be exported.

=cut

{ no strict q/vars/;
  no warnings;
*enc = *goedel;
}

=head1 REFERENCES

Goedel number: L<http://en.wikipedia.org/wiki/G%C3%B6del_number>

Discussion of "how to make goedel number unique" (in Japanese):
L<http://ja.doukaku.org/comment/4657/>, L<http://ja.doukaku.org/comment/4661/>

=head1 AUTHOR

KATOU Akira (turugina), C<< <turugina at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-math-goedel at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Math-Goedel>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Math::Goedel


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Math-Goedel>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Math-Goedel>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Math-Goedel>

=item * Search CPAN

L<http://search.cpan.org/dist/Math-Goedel>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2008 KATOU Akira (turugina), all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of Math::Goedel
