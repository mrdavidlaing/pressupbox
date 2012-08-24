maintainer       "David Laing"
maintainer_email "david@davidlaing.com"
license          "Apache 2.0"
description      "Install multitail - better tail"
version          "0.0.1"

%w{ ubuntu debian }.each do |os|
  supports os
end
