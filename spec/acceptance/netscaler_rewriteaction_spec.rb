require 'spec_helper_acceptance'

describe 'rewriteaction' do
  it 'makes a rewriteaction 1' do
    pp=<<-EOS
netscaler_rewriteaction { '2_9_rewriteaction_test1':
  ensure              => 'present',
  type                => 'insert_http_header',
  target_expression   => 'This is the header name',
  content_expression  => 'HTTP.REQ.HEADER("host")',
  bypass_safety_check => 'YES',
  comments            => 'this is a comment',
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'makes a rewriteaction 2' do
    pp=<<-EOS
netscaler_rewriteaction { '2_9_rewriteaction_test2':
  ensure              => 'present',
  type                => 'insert_after',
  target_expression   => 'HTTP.REQ.HEADER("host")',
  content_expression  => '"-belfast"',
  bypass_safety_check => 'YES',
  comments            => 'this is a comment',
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'makes a rewriteaction 3' do
    pp=<<-EOS
netscaler_rewriteaction { '2_9_rewriteaction_test3':
  ensure              => 'present',
  type                => 'insert_before_all',
  target_expression   => 'HTTP.RES.BODY(1000)',
  content_expression  => '"-belfast"',
  search              => 'text("testsearch")',
  refine_search       => 'extend(2,4)',
  bypass_safety_check => 'YES',
  comments            => 'this is a comment',
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'makes a rewriteaction 4' do
    pp=<<-EOS
netscaler_rewriteaction { '2_9_rewriteaction_test4':
  ensure              => 'present',
  type                => 'insert_before_all',
  target_expression   => 'HTTP.RES.BODY(1000)',
  content_expression  => '"-belfast"',
  pattern             => 'regex("/searchtext/")',
  refine_search       => 'extend(2,4)',
  bypass_safety_check => 'YES',
  comments            => 'this is a comment',
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'makes and deletes javascript rewriteaction' do
    pp=<<-EOS
netscaler_rewriteaction { 'my_rw_default_insert_after_body':
  ensure              => 'present',
  bypass_safety_check => 'NO',
  content_expression  => '"<script language=\\'javascript1.1\\' type=\\"text/javascript\\">" + " /*Script contents copyright Puppetlabs 2015, and implementation" + " covered by international intellectual property laws.*/" + "\\nfunction  _aaatm_NSST(e){if(document.readyState==\\"complete\\"){_aaatm_NSLG();}}" + "if(window.addEventListener){window.addEventListener(\\'load\\',_aaatm_NSLG(),false);} else" + " if(window.attachEvent&&document.attachEvent){document.attachEvent(\\'onreadystatechange\\',_aaatm_NSST);}" + "function _aaatm_NSLG(m){setTimeout(\\"_aaatm_NSLG1()\\", 5000);}\\n" + "function _aaatm_NSLG1(){var o=new Image();if(o){o.src=\\'/cgi/tmlogout\\';}}" + "</script>"',
  target_expression   => 'HTTP.RES.BODY(0)',
  type                => 'insert_after',
}
    EOS

    pp2=<<-EOS
netscaler_rewriteaction { 'my_rw_contains_javascript':
  ensure              => 'absent',
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    make_site_pp(pp2)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'makes and deletes another rewriteaction' do
    pp=<<-EOS
netscaler_rewriteaction { '2_9_rewriteaction_test5':
  ensure              => 'present',
  type                => 'insert_before_all',
  target_expression   => 'HTTP.RES.BODY(1000)',
  content_expression  => '"-belfast"',
  pattern             => 'regex("/searchtext/")',
  refine_search       => 'extend(2,4)',
  bypass_safety_check => 'YES',
  comments            => 'this is a comment',
}
    EOS

    pp2=<<-EOS
netscaler_rewriteaction { '2_9_rewriteaction_test5':
  ensure              => 'absent',
}
    EOS

    make_site_pp(pp)
    run_device(:allow_changes => true)
    make_site_pp(pp2)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end
end
