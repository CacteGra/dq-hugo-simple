---
title: "Encoding HTML to PDF: WKHTMLTOPDF"
date: 2025-10-01
draft: false
tags: ["dev", "webdev"]
categories: ["tutorial"]
description: "A weird bug on GitHub causing an impossibility to switch repository branch."
---
**PDF** clearly is a file format that Adobe underdeveloped to say the least (since 1992!) and its release as an open standard in 2008 has not been followed by bettering improvement; its usability to performance to quality have long been a source of longing for many looking for a replacement (I look at you **Markdown**). Converting to PDF still is mindbogglingly frustrating (loss in quality, formatting issues, ...).

Alas, any shared text files are mostly in .pdf format ([academic papers among the first](https://pdfa.org/wp-content/uploads/2018/06/1330_Johnson.pdf)).
That said, we need good tools to make good .pdf files.


## Getting to know wkhtmlto
**WKHTMLTOPDF** is one of them. While the repository has been archived, wkhtmltopdf is still well worth it. You can also take a look at [Puppeteer](https://github.com/puppeteer/puppeteer) a headless JavaScript library controlling  Chrome/Firefox through an API and it can therefore generate PDFs. This one might be circumvoluted to use and for quick and easy conversion wkhtml see better.

All you need to do is [download the program](https://wkhtmltopdf.org/downloads.html) and run the following command to convert an online **web page** to a local PDF file:  
`wkhtmltopdf http://google.com google.pdf`  
Or for a **local file**:  
`wkhtmltopdf local-file.html local-file.pdf`

Et voilà! Your **HMTL** page has been transformed into a **PDF file**. There are however caveats and one of them is the use of special or even custom fonts (make sure it is compatible [here](https://developer.mozilla.org/en-US/docs/Web/CSS/@font-face)). Including fonts like this:  
`<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600" rel="stylesheet">`  
It will not work; the resulting PDF file will only be an image of the web page with text that cannot be selected.

## Fixing Unselectable text
Getting "selectable" text with linked fonts necessitate a few extra steps, mainly encoding the font to **Base64** and including it to your HTML file.
To encode your font to Base64 use [this site](https://amio.github.io/embedded-google-fonts/), just paste font URL, for example:  
`https://fonts.googleapis.com/css2?family=Source+Code+Pro:ital,wght@0,200..900;1,200..900`

And the website will directly output an embedded Base64 font for your CSS style. A word of caution here, it will output multiple **@font-face** if the linked font has them: choose one of them.  
Dump it (or include it) in your HMTL file, and retry wkhtmlto and it should work flawlessly.  
## Example
Here is an example using my resume in [HTML](/html/resume-example.html), and its [output in .pdf](/images/posts/html-to-pdf-resume-example.png).    
  
    
   
     
     
  
  

## ---  

###### Thanks to [Ranjith kumar](https://codingislove.com/author/ranjithkumar10/)'s [article](https://codingislove.com/custom-font-pdfkit-wkhtmltopdf/) which helped me a great deal.