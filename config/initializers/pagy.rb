require 'pagy/extras/array'
require 'pagy/extras/i18n'
require 'pagy/extras/overflow'
require 'pagy/extras/support'

Pagy::DEFAULT[:items] = 10
Pagy::DEFAULT[:size] = [1, 1, 1, 1]
Pagy::DEFAULT[:overflow] = :last_page
