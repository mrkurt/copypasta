require 'spec_helper'

describe ReceivedEmail do
  it "properly parses email addresses" do
    e = 'copypasta+edit-52-6f432a2e0dd5@credibl.es'
    result = ReceivedEmail.parse_address(e)
    result[:id].should == '52'
    result[:key].should == '6f432a2e0dd5'
  end

  it "parses body properly" do
    body = <<EOF
Useless!

On Sun, Jan 23, 2011 at 1:28 PM, copypasta <
copypasta+edit-53-56b80de5e942@credibl.es<copypasta%2Bedit-53-56b80de5e942@credibl.es>
> wrote:

> (Anonymous) just submitted a correction for one of your pages:
> http://dl.dropbox.com/u/167533/copypasta-test.html
>
> Changes:
> ...href="http://mortimer.fas.harvard.edu/concerts_01oct2010.pdf">recent
> academic paper</a> confirms. This is particularly true for very popular
> ---music--- +++moo-sic+++ groups.
>
> ***copypasta instructions***
> Responses to this email will be sent to the submitter.
> Everything below the instructions will be stripped out.
> To change the status of this edit, put an x between the brackets:
> [  ] accept
> [ x ] reject
>
EOF
    result = ReceivedEmail.parse_body(body, '56b80de5e942')

    result[:status].should == 'rejected'
    result[:message].should_not include('56b80de5e942')
    result[:message].should_not include('***copypasta instructions***')
  end
end
