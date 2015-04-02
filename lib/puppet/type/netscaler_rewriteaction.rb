require 'puppet/parameter/netscaler_name'
require 'puppet/property/netscaler_truthy'
require 'puppet/property/netscaler_traffic_domain'

Puppet::Type.newtype(:netscaler_rewriteaction) do
  @doc = 'Manage basic netscaler rewrite action objects.'

  apply_to_device
  ensurable

  newparam(:name, :parent => Puppet::Parameter::NetscalerName, :namevar => true)
  newproperty(:type) do
    desc "Type of rewrite action. It can be: (replace|insert_http_header|delete_http_header|corrupt_http_header|insert_before|insert_after|delete|replace_http_res).
    For each action type the <target> and <string builder expr> are defined below.

      o insert_http_header: Will insert a HTTP header.
        <target_expression> = header name.
        <content_expression> = header value specified as a compound text expression.

      o insert_sip_header: Will insert a SIP header.
        <target_expression> = header name.
        <content_expression> = header value specified as a compound text expression.

      o delete_http_header: Will delete all occurrence of HTTP header.
        <target_expression> = header name.

      o delete_sip_header: Will delete all occurrence of SIP header.
        <target_expression> = header name.

      o corrupt_http_header: Will corrupt all occurrence of HTTP header.
        <target_expression> = header name.

      o corrupt_sip_header: Will corrupt all occurrence of SIP header.
        <target_expression> = header name.

      o replace: Will replace the target text reference with the value specified in attr.
        <target_expression> = Advanced text expression
        <content_expression> = Compound text expression

      o insert_before: Will insert the value specified by attr before the target text reference.
        <target_expression> = Advanced text expression
        <content_expression> = Compound text expression

      o insert_after: Will insert the value specified by attr after the target text reference.
        <target_expression> = Advanced text expression
        <content_expression> = Compound text expression

      o delete: Delete the target text reference.
        <target_expression> = Advanced text expression

      o replace_http_res: Replace the http response with value specified in target.
        <target_expression> = Compound text expression

      o replace_sip_res: Replace the SIP response with value specified in target.
        <target_expression> = Compound text expression

      o replace_all: Replaces all occurrence of the pattern in the text provided in the target with the text provided in the stringBuilderExpr, with a string defined in the -pattern argument or -search argument.
        For example, you can replace all occurences of abcd with -pattern efgh.
        <target_expression> = text in a request or a response, for example http.req.body(1000)
        <content_expression> = Compound text expression
        -pattern <expression> = string constant, for example -pattern efgh or -search text(\"efgh\")

      o insert_before_all: Will insert the value specified by stringBuilderExpr before all the occurrence of pattern in the target text reference.
        <target_expression> = Advanced text expression
        <content_expression> = Compound text expression
        -pattern <expression> = string constant or advanced regular expression or
        -search regex(<regular expression>) or -search text(string constant)

      o insert_after_all: Will insert the value specified by stringBuilderExpr after all the occurrence of pattern in the target text reference.
        <target_expression> = Advanced text expression
        <content_expression> = Compound text expression
        -pattern <expression> = string constant or advanced regular expression or
        -search regex(<regular expression>) or -search text(string constant)

      o delete_all: Delete all the occurrence of pattern in the target text reference.
        <target_expression> = Advanced text expression
        -pattern <expression> = string constant or advanced regular expression or
        -search regex(<regular expression>) or -search text(string constant)"

    validate do |value|
      if ! [:noop,:delete,:insert_http_header,:delete_http_header,:corrupt_http_header,:insert_before,:insert_after,:replace,:replace_http_res,:delete_all,:replace_all,:insert_before_all,:insert_after_all,:clientless_vpn_encode,:clientless_vpn_encode_all,:clientless_vpn_decode,:clientless_vpn_decode_all,:insert_sip_header,:delete_sip_header,:corrupt_sip_header,:replace_sip_res,].any?{ |s| s.casecmp(value.to_sym) == 0 }
          fail ArgumentError, "Valid options: noop, delete, insert_http_header, delete_http_header, corrupt_http_header, insert_before, insert_after, replace, replace_http_res, delete_all, replace_all, insert_before_all, insert_after_all, clientless_vpn_encode, clientless_vpn_encode_all, clientless_vpn_decode, clientless_vpn_decode_all, insert_sip_header, delete_sip_header, corrupt_sip_header, replace_sip_res"
      end
    end

    munge(&:downcase)
  end

  newproperty(:target_expression) do
    desc "Default syntax expression that specifies which part of the request or response to rewrite."
  end

  newproperty(:content_expression) do
     desc "Default syntax expression that specifies the content to insert into the request or response at the specified location, or that replaces the specified string. Applicable for the following types: INSERT_HTTP_HEADER, INSERT_SIP_HEADER, REPLACE, INSERT_BEFORE, INSERT_AFTER, REPLACE_ALL, INSERT_BEFORE_ALL, INSERT_AFTER_ALL."
  end

  newproperty(:pattern) do
    desc "Pattern to be used for INSERT_BEFORE_ALL, INSERT_AFTER_ALL, REPLACE_ALL, DELETE_ALL action types."
  end

  newproperty(:search) do
    desc "search expression takes the followin 5 argumens to use the appropriate methods to search in the specified body or header:
  1. text(string) - example: -search text(\"hello\")
  2. regex(re<delimiter>regular exp<delimiter>) - example: -search regex(re/^hello/)
  3. xpath(xp<delimiter>xpath expression<delimiter>) - example: -search xpath(xp%/a/b%)
  4. xpath_json(xp<delimiter>xpath expression<delimiter>) - example: -search xpath_json(xp%/a/b%)
    xpath_json_search takes xpath expression as argument but operates on json file instead of xml file.
  5. patset(patset) - example: -search patset(\"patset1\")

  search expression are allowed on actions of type
  1) REPLACE_ALL
  2) INSERT_AFTER_ALL
  3) DELETE_ALL
  4) INSERT_BEFORE_ALL.
  search is a super set of pattern. It is advised to use search over pattern."
  end

  newproperty(:bypass_safety_check, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("Bypass the safety check and allow unsafe expressions.", 'YES', 'NO')
  end

  newproperty(:refine_search) do
    desc "refineSearch expressions specifies how the selected HTTP data can further be refined. These expression always starts with the 'Extend(m,n)' operation. Where 'm' specifies number of bytes to the left of selected data and 'n' specifies number of bytes to the right of selected data.
  refineSearch expression are only allowed on body based expression and for actions of type
  1) REPLACE_ALL
  2) INSERT_AFTER_ALL
  3) DELETE_ALL
  4) INSERT_BEFORE_ALL.
  This can accelerate search using regular expression. For example if we need to find all the urls from www.zippo.com in a response body. Rather than writing a regular expression to search this url pattern we can search for 'zippo' pattern first and then extend the search space by some bytes and finally check for prefix 'www.zippo.com'. The rewrite command might look like:
        add rewrite action act1 delete_all 'http.res.body(10000)' -pattern \"zippo\" -refineSearch \"extend(10,10).regex_select(re%<www.zippo.com[^>].*>%)\"
  Maximum length of the input expression is 8191. Maximum size of string that can be used inside the expression is 1499."
  end

  newproperty(:comments) do
    desc "Comments associated with this rewrite action."
  end
end
