
examples = 0

function isTikz(fname)
  return string.find(fname,".tikz") or string.find(fname,".tex")
end

-- Draft text, for the author to review: ::: {.draft} blocks and [text]{.draft}
-- spans are set in the color "draftcolor" (defined in latex/preamble.tex) in
-- the PDF, and styled by the .draft rule added to the HTML header below.
function draftBlock(el)
   return {
      pandoc.RawBlock('latex', "\\begingroup\\color{draftcolor}"),
      el,
      pandoc.RawBlock('latex', "\\endgroup")
   }
end

function draftInline(el)
   local out = { pandoc.RawInline('latex', "\\protect\\textcolor{draftcolor}{") }
   for _, v in ipairs(el.content) do table.insert(out, v) end
   table.insert(out, pandoc.RawInline('latex', "}"))
   return out
end

if FORMAT:match 'latex' then
  function Span(el)
      if el.classes:includes'draft' then
         return draftInline(el)
      end
  end
  function Div(el)
      if el.classes:includes'draft' then
         return draftBlock(el)
      end
      if el.classes:includes'example' then
      	 examples = examples + 1
	 if el.attributes['ref'] then
            return {
   	       pandoc.RawBlock('latex',"\\begin{example}{"..el.attributes['title'].."}"),
   	       pandoc.RawBlock('latex',"{"..el.attributes['ref'].."}"),
   	       el,
	       pandoc.RawBlock('latex',"\\end{example}")
	    }
	 elseif el.attributes['title'] then
            return {
   	       pandoc.RawBlock('latex',"\\begin{example}{"..el.attributes['title'].."}{}"),
   	       el,
	       pandoc.RawBlock('latex',"\\end{example}")
	    }
	 else
            return {
	      pandoc.RawBlock('latex',"\\begin{example}{}{}"),
	      el,
	      pandoc.RawBlock('latex',"\\end{example}")
	    }
	 end
      end      
  end
  function Image(el)

      ref=pandoc.RawInline('latex',"")
      if el.attributes['ref'] then
         ref=pandoc.RawInline('latex',el.attributes['ref'])
      end

      figtype="figure"      
      opts = ""

      src=el.src

      includeStr=""
      if (isTikz(src)) then
         includeStr="\\input{"..src.."}"
      else
         includeStr="\\includegraphics{"..src.."}"
      end

      texstr = {
   	 --pandoc.RawInline('latex',"\\begin{"..figtype.."}"..opts.."\\centering"),
	 pandoc.RawInline('latex',includeStr),
	 --pandoc.RawInline('latex',"\\caption{")
      }
      --[[
      for i,v in ipairs(el.caption) do
         table.insert(texstr,v)
      end
      ]]
      --[[
      table.insert(texstr,pandoc.RawInline('latex',"}"))
      table.insert(texstr,pandoc.RawInline('latex',"\\label{"))
      table.insert(texstr,	 ref)
      table.insert(texstr,pandoc.RawInline('latex',"}"))
      table.insert(texstr,pandoc.RawInline('latex',"\\end{"..figtype.."}"))
      ]]
      return texstr
   end
end

if FORMAT:match 'html' then
  function Meta(m)
      local css = pandoc.MetaBlocks{pandoc.RawBlock('html',
         '<style>.draft { color: #a40000; }</style>')}
      local hi = m['header-includes']
      if hi == nil then
         m['header-includes'] = pandoc.MetaList{css}
      elseif pandoc.utils.type(hi) == 'List' then
         hi:insert(css)
         m['header-includes'] = hi
      else
         m['header-includes'] = pandoc.MetaList{hi, css}
      end
      return m
  end
  function Div(el)
      if el.classes:includes'example' then
      	 examples = examples + 1
	 
         return {
	   pandoc.Header(3,'Example '..examples),
	   el
	 }
      end      
  end
end


