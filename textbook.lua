
examples = 0

function isTikz(fname)
  return string.find(fname,".tikz") or string.find(fname,".tex")
end

if FORMAT:match 'latex' then
  function Div(el)
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
      print(src)

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


