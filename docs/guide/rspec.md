---
order: 3
---

# Apiwork RSpec

Apiwork RSpec is an RSpec extension for Apiwork. It reads your Apiwork definitions and asserts their structure — attributes, enums, filters, and actions.

Install:

```ruby
gem 'apiwork-rspec', group: :test
```

Full documentation: [apiwork-rspec](https://github.com/skiftle/apiwork-rspec).

## Setup

```ruby
RSpec.configure do |config|
  config.include Apiwork::RSpec::Matchers
end
```

## API Definitions

Use `Apiwork::API.find!` as the subject:

```ruby
RSpec.describe 'Billing API' do
  subject { Apiwork::API.find!('/api/v1') }

  it { is_expected.to have_key_format(:camel) }
  it { is_expected.to have_path_format(:kebab) }
  it { is_expected.to have_export(:openapi) }
  it { is_expected.to have_raises(:bad_request, :internal_server_error) }

  it { is_expected.to have_resource(:invoices) }
  it { is_expected.to have_resource(:invoices).with_only(:index, :show) }
  it { is_expected.to have_resource(:lines).under(:invoices) }
  it { is_expected.to have_resource(:profile).singular }

  describe_info do
    it { is_expected.to have_title('Billing API') }
    it { is_expected.to have_version('1.0.0') }
    it { is_expected.to define_contact('API Support').with_email('support@example.com') }
    it { is_expected.to define_license('MIT') }
    it { is_expected.to define_server('https://api.example.com').with_description('Production') }
  end
end
```

`describe_info` switches the subject to the API's info block.

## Contracts

Use the contract class as the subject:

```ruby
RSpec.describe InvoiceContract do
  subject { described_class }

  it { is_expected.to have_representation(InvoiceRepresentation) }
  it { is_expected.to have_identifier(:invoices) }
  it { is_expected.to have_import(SharedContract, as: :shared) }
end
```

`describe_action` switches the subject to a specific action. From there, nest into request/response and body/query:

```ruby
describe_action :create do
  it { is_expected.to have_summary('Create invoice') }
  it { is_expected.to have_tags(:billing) }

  describe_request do
    describe_body do
      it { is_expected.to have_param(:title).of_type(:string).required }
      it { is_expected.to have_param(:notes).of_type(:string).optional.nullable }
      it { is_expected.to have_param(:status).with_enum(%w[draft sent]).with_default('draft') }
      it { is_expected.to have_param(:amount).of_type(:decimal).with_min(0).with_max(1_000_000) }
    end
  end

  describe_response do
    describe_body do
      it { is_expected.to have_param(:id).of_type(:uuid) }
    end
  end
end

describe_action :destroy do
  it { is_expected.to be_no_content }
end
```

The nesting mirrors the contract DSL. Each level switches the subject so `have_param` targets the right scope.

`describe_param` nests into inline types:

```ruby
describe_body do
  it { is_expected.to have_param(:address).of_type(:object) }

  describe_param :address do
    it { is_expected.to have_param(:street).of_type(:string) }
    it { is_expected.to have_param(:city).of_type(:string) }
  end
end
```

## Representations

Use the representation class as the subject:

```ruby
RSpec.describe InvoiceRepresentation do
  subject { described_class }

  it { is_expected.to have_model(Invoice) }
  it { is_expected.to have_root(:invoice, :invoices) }

  it { is_expected.to have_attribute(:title).of_type(:string).writable }
  it { is_expected.to have_attribute(:total).of_type(:decimal).filterable.sortable }
  it { is_expected.to have_attribute(:status).with_enum(%w[draft sent paid]) }
  it { is_expected.to have_attribute(:notes).optional.nullable }

  it { is_expected.to have_association(:lines).of_type(:has_many).writable.allow_destroy }
  it { is_expected.to have_association(:customer).of_type(:belongs_to).with_include(:always) }
  it { is_expected.to have_association(:payable).polymorphic }
end
```

Matchers chain the same modifiers you use in the representation DSL.

## Types

Enums, objects, and unions can live at both API and contract level.

`describe_object` and `describe_union` switch the subject to a named type:

```ruby
it { is_expected.to define_enum(:status).with_values(%w[draft sent paid]) }

describe_object :address do
  it { is_expected.to have_param(:street).of_type(:string) }
  it { is_expected.to have_param(:city).of_type(:string) }
end

describe_union :recipient do
  it { is_expected.to have_discriminator(:type) }
  it { is_expected.to have_variant(:customer).of_type(:customer) }
  it { is_expected.to have_variant(:company).of_type(:company) }
end
```

#### See also

- [apiwork-rspec on GitHub](https://github.com/skiftle/apiwork-rspec) — full matcher reference
