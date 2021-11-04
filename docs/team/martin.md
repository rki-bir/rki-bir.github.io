<!-- https://www.xul.fr/en/css/bar-chart.php -->
<script>
function makeGraph(container, labels)
{
    container = document.getElementById(container);
    labels = document.getElementById(labels)
    var dnl = container.getElementsByTagName("li");
    for(var i = 0; i < dnl.length; i++)
    {
        var item = dnl.item(i);
        var value = item.innerHTML;
        var color = item.style.background=color;
        var content = value.split(":");
        value = content[0];
        item.style.height=value + "px";
        item.style.top=(199 - value) + "px";
        item.style.left = (i * 50 + 20) + "px";
        item.style.height = value + "px";
        item.innerHTML = value;
        item.style.visibility="visible";	
        color = content[2];
        if(color != false) item.style.background=color;
        labels.innerHTML = labels.innerHTML +
             /*"<span style='margin:8px;background:"+ color+"'>" +*/
             "<span style='margin:8px;'>" + 
             content[1] + "</span>";
    }	
}

window.onload=function () { makeGraph("graph", "labels") }
</script>

# Head [![Twitter Follow](https://img.shields.io/twitter/follow/martinhoelzer.svg?style=social){align="right"}](https://twitter.com/martinhoelzer)

## Martin Hölzer <font size="3">PhD</font> ![](/team/martin.png#shadow#round){style="width:120px" align="left"} 
[:octicons-mail-16: Email](mailto:hoelzer.martin@gmail.com)&nbsp;&nbsp;&nbsp;
[:octicons-book-16: Google Scholar](https://scholar.google.com/citations?user=YSWxKeoAAAAJ&hl=en)&nbsp;&nbsp;&nbsp;
[:octicons-person-16: ORCID](https://orcid.org/0000-0001-7090-8717)&nbsp;&nbsp;&nbsp;
[:octicons-mark-github-16: GitHub](https://github.com/hoelzer) 

Martin is deputy head of the Bioinformatics unit and responsible for research in the BIR team. His expertise is in RNA-Seq, metagenomics, nanopore sequencing, virus detection, nextflow and containerization. He is PI of the project team _Positive selection and pathogen evolution_. 

<!--
<div id="graph">
  200<br/> <br/> 150 <br/> <br/> 100 <br/> <br/> 50
    <ul>  
        <li>39:2018:grey</li>
        <li>68:2019:grey</li>
        <li>168:2020:grey</li>
        <li>330:2021:grey</li>
    </ul>
<div id="labels"><br/><br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</div>
</div>
-->
<!--lightblue-->

<!-- PUBLICATIONS WILL BE AUTOMATICALLY ADDED HERE VIA THE GITHUB CI -->
