# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#
#

#updateContent = ->
#      selectedFormat = $( "#selectformat option:selected").text()
#      selectedPersonId = $("#selectname option:selected").attr("id")
#
#      url = "/people/" + selectedPersonId + "/" + selectedFormat
#      jQuery.ajax({
#          type: "GET",
#          url: url,
#          #data: data,
#          dataType:"text",
#          success:  (data, status, jqXHR) ->
#              $( "#content").val(data)
#          error:    (jqXHR, statusa) ->
#              $( "#content").val("Error loading format Status:" + status + " " + jqXHR)
#      })
#
#
#addNewPerson = ->
#      name = $( "#newpersonname").val()
#      format = $("#selectformatfornewperson option:selected").val()
#      content = $("#newpersoncontent").val()
#      console.log "name:  " + format
#      url = "/people/new" 
#      jQuery.ajax({
#          type: "POST",
#          url: url,
#          data: {name: name, format: format, content: content},
#          dataType:"text",
#          success:  (data, status, jqXHR) ->
#              $( "#content").text(data)
#              window.location.replace("/people")
#          error:    (jqXHR, statusa) ->
#              $( "#content").text("Error loading format Status:" + status)
#      })
#
#ready = ->
#    $('#selectformat').change( ->
#      updateContent()
#    )
#
#    $('#selectname').change( ->
#      updateContent()
#    )
#
#    $('#submitnewperson').click( ->
#      console.log "hallo hallo"
#      addNewPerson()
#    )
#
#$(document).ready(ready)
#$(document).on('page:load', ready)
#updateContent()
