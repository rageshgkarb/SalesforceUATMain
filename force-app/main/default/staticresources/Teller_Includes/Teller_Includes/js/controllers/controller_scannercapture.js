tellerApp.controller('controllerScannerCapture', ['$scope', '$state', '$stateParams', '$window', 'serviceParameters', 'serviceApplication', 'serviceCustomer', 
    function($scope, $state, $stateParams, $window, serviceParameters, serviceApplication, serviceCustomer)
{
	$scope.CurrentSourceId = 0;
	$scope.Sources = null;
	$scope.VideoElement = null;
	
    $scope.CapturedImage = null;
	$scope.Captured = false;
	$scope.CanvasElement = null;
    $scope.Cropped = false;

    $scope.SignaturePadElement = null;

    $scope.SelectedOption = '';

    $scope.ImagePosition = new function()
    {

        this.Left = 0;
        this.Top = 0;
        this.Right = 0;
        this.Bottom = 0;

        this.Initialise = function()
        {
            this.Left = 0;
            this.Top = 0;
            this.Right = 0;
            this.Bottom = 0;
        };
    }

    $scope.Initiate = function()
    {   	
        //Initiate drag and drop
        $scope.InitiateDragDrop();

    	//Initiate scanner
        Dynamsoft.WebTwainEnv.Unload();
        Dynamsoft.WebTwainEnv.Load();

        //Initilaise Signature pad
        $scope.InitiateSignaturePad();
    }

    $scope.Close = function()
    {
        serviceApplication.ModalHide();
    }

    $scope.Crop = function() 
    {
        switch($scope.SelectedOption)
        {
            case 'Scan':
            {
                var DWObject = Dynamsoft.WebTwainEnv.GetWebTwain('dwtcontrolContainer');
                if (DWObject.HowManyImagesInBuffer > 0) {
                    if ($scope.ImagePosition.Left != 0 || $scope.ImagePosition.Top != 0 || $scope.ImagePosition.Right != 0 || $scope.ImagePosition.Bottom != 0) {
                        DWObject.Crop(
                            DWObject.CurrentImageIndexInBuffer,
                            $scope.ImagePosition.Left, $scope.ImagePosition.Top, $scope.ImagePosition.Right, $scope.ImagePosition.Bottom);
                        $scope.ImagePosition.Initialise();
                    }
                }
                break;
            }

            case 'DragDrop':
            {
                $scope.Cropped = true;
                break;
            }

            case 'Signature':
            {
                break;
            }
        }  
    }

    $scope.GoBack = function()
    {
        if($scope.Captured == false)
        {
            $scope.SelectedOption = '';
        }
        else if($scope.SelectedOption == 'Scan')
        {
            $scope.Cropped = false;
            $scope.Captured = false;

            var DWObject = Dynamsoft.WebTwainEnv.GetWebTwain('dwtcontrolContainer');
            DWObject.RemoveAllImages();
        }
        else 
        {
            if($scope.Cropped)
            {
                $scope.Cropped = false;
            }
            else
            {
                if($scope.Captured == false)
                {
                    $scope.SelectedOption = '';
                }
                else
                {
                    $scope.BackToImageCapture();
                }
            }
        }          
    }

    $scope.Save = function()
    {
        serviceApplication.LoadShow('Saving signature');

        var base64String = null;

        if($scope.SelectedOption == 'Scan')
        {
            var DWObject = Dynamsoft.WebTwainEnv.GetWebTwain('dwtcontrolContainer');
            DWObject.SelectedImagesCount = 1;
            DWObject.SetSelectedImageIndex(0,DWObject.SelectedImagesCount-1); // Set the last image as the selected image
            DWObject.GetSelectedImagesSize(1); 
            base64String = DWObject.SaveSelectedImagesToBase64Binary();
        }
        
        if($scope.SelectedOption == 'DragDrop')
        {
            base64String = document.getElementById('croppedImg').src;
            base64String = base64String.replace(/^data:image\/(png|jpg);base64,/, "");
        }

        if($scope.SelectedOption == 'Signature')
        {
            base64String = $scope.SignaturePadElement.toDataURL();
            base64String = base64String.replace(/^data:image\/(png|jpg);base64,/, "");
        }
        
        serviceCustomer.SaveCustomerImages(serviceParameters.CustomerParams.SelectedEBSId, "Signature", base64String)
            .then(
                function(result) 
                {
                    if (!result) 
                    {
                        alert('Failed to save');
                        serviceApplication.LoadHide();
                    } 
                    else 
                    {
                        serviceApplication.LoadHide();
                        $scope.Close();
                    }
                },
                function(error) 
                {
                    alert(error.message);
                    serviceApplication.LoadHide();
                }
        );
    }

    //---- SignaturePad

    $scope.InitiateSignaturePad = function()
    {
        //https://github.com/szimek/signature_pad
        var element = document.getElementById('signaturePad');
        $scope.SignaturePadElement = new SignaturePad(element);
    }

    $scope.ClearSignature = function()
    {
        $scope.SignaturePadElement.clear();
    }

    //---- Dynamsoft

    $scope.AcquireImage = function() {      

        $scope.Captured = true;

        var DWObject = Dynamsoft.WebTwainEnv.GetWebTwain('dwtcontrolContainer'); // Get the Dynamic Web TWAIN object that is embeded in the div with id 'dwtcontrolContainer'.
        
        DWObject.RegisterEvent("OnPostTransfer", $scope.Dynamsoft_OnPostTransfer);
        DWObject.RegisterEvent("OnImageAreaSelected", $scope.Dynamsoft_OnImageAreaSelected);
        DWObject.RegisterEvent("OnImageAreaDeselected", $scope.Dynamsoft_OnImageAreaDeselected);
        
        DWObject.IfDisableSourceAfterAcquire = true; // Source will be closed automatically after acquisition.
        DWObject.SelectSource(); // Select a Data Source (a device like scanner) from the Data Source Manager.            
        DWObject.OpenSource(); // Open the source. You can set resolution, pixel type, etc. after this method. Please refer to the sample 'Scan' -> 'Custom Scan' for more info.
        DWObject.AcquireImage(); // Acquire image(s) from the Data Source. Please NOTE this is a asynchronous method. In other words, it doesn't wait for the Data Source to come back. 
        // In order to do things during the scanning, you can use the events OnPostTransfer and OnPostAllTransfers. Please check out the sample UseEvent.html
    }

    //---- Drag & Drop

    $scope.InitiateDragDrop = function()
    {
        if (typeof window.FileReader === 'undefined') 
        {
            console.log('File API & FileReader unavailable');
        } 
        else 
        {
          console.log('File API & FileReader available');
        }


        var dragdropContainer = document.getElementById("dragdropContainer");
        dragdropContainer.ondragover = function(e)
        {
            console.log('drag over');
            e.preventDefault();
            return false;
        };

        dragdropContainer.ondragenter = function(e) 
        {
            e.preventDefault();
            return false;
        };

        dragdropContainer.ondragleave = function(e) 
        {
            e.preventDefault();
            return false;
        };

        dragdropContainer.ondrop  = function(e)
        {
            e.preventDefault();
            console.log('drag file drppped');
            var file = e.dataTransfer.files[0],
                reader = new FileReader();

            reader.onload = function(event) 
            {                
                console.log(event.target);
                document.getElementById('canvasImg').src = event.target.result;
                resizeableImage(document.getElementById('canvasImg'));
            };

            console.log(file);
            reader.readAsDataURL(file);
            $scope.Captured = true;
            $scope.$apply();
            return false;
        }
    }

    $scope.BackToImageCapture = function()
    {
        $scope.Cropped = false;
        $scope.Captured = false;
        var newParent = document.getElementById('cameraContainer');
        var element = document.getElementById('canvasImg');
        newParent.appendChild(element);
        var toRemove = document.getElementsByClassName('resize-container');
        newParent.removeChild(toRemove[0]);
    }
    
    //---- Crop and Resize

    var resizeableImage = function(image_target) 
    {
        // Some variable and settings
        var $container,
            orig_src = new Image(),
            image_target = $(image_target).get(0),
            event_state = {},
            constrain = true, //Always constrain
            min_width = 60, // Change as required
            min_height = 60,
            max_width = 10000, // Change as required
            max_height = 10000,
            resize_canvas = document.createElement('canvas');

        init = function() {

            // When resizing, we will always use this copy of the original as the base
            orig_src.src = image_target.src;

            // Wrap the image with the container and add resize handles
            $(image_target).wrap('<div class="resize-container" style="top: 8px; left: 9px;"></div>')
                .before('<span class="resize-handle resize-handle-nw"></span>')
                .before('<span class="resize-handle resize-handle-ne"></span>')
                .after('<span class="resize-handle resize-handle-se"></span>')
                .after('<span class="resize-handle resize-handle-sw"></span>');

            // Assign the container to a variable
            $container = $(image_target).parent('.resize-container');

            // Add events
            $container.on('mousedown touchstart', '.resize-handle', startResize);
            $container.on('mousedown touchstart', 'img', startMoving);
            $('.js-crop').on('click', crop);
        };

        startResize = function(e) {
            e.preventDefault();
            e.stopPropagation();
            saveEventState(e);
            $(document).on('mousemove touchmove', resizing);
            $(document).on('mouseup touchend', endResize);
        };

        endResize = function(e) {
            e.preventDefault();
            $(document).off('mouseup touchend', endResize);
            $(document).off('mousemove touchmove', resizing);
        };

        saveEventState = function(e) {
            // Save the initial event details and container state
            event_state.container_width = $container.width();
            event_state.container_height = $container.height();
            event_state.container_left = $container.offset().left;
            event_state.container_top = $container.offset().top;
            event_state.mouse_x = (e.clientX || e.pageX || e.originalEvent.touches[0].clientX) + $(window).scrollLeft();
            event_state.mouse_y = (e.clientY || e.pageY || e.originalEvent.touches[0].clientY) + $(window).scrollTop();

            // This is a fix for mobile safari
            // For some reason it does not allow a direct copy of the touches property
            if (typeof e.originalEvent.touches !== 'undefined') {
                event_state.touches = [];
                $.each(e.originalEvent.touches, function(i, ob) {
                    event_state.touches[i] = {};
                    event_state.touches[i].clientX = 0 + ob.clientX;
                    event_state.touches[i].clientY = 0 + ob.clientY;
                });
            }
            event_state.evnt = e;
        };

        resizing = function(e) {
            var mouse = {},
                width, height, left, top, offset = $container.offset();
            mouse.x = (e.clientX || e.pageX || e.originalEvent.touches[0].clientX) + $(window).scrollLeft();
            mouse.y = (e.clientY || e.pageY || e.originalEvent.touches[0].clientY) + $(window).scrollTop();

            // Position image differently depending on the corner dragged and constraints
            if ($(event_state.evnt.target).hasClass('resize-handle-se')) {
                width = mouse.x - event_state.container_left;
                height = mouse.y - event_state.container_top;
                left = event_state.container_left;
                top = event_state.container_top;
            } else if ($(event_state.evnt.target).hasClass('resize-handle-sw')) {
                width = event_state.container_width - (mouse.x - event_state.container_left);
                height = mouse.y - event_state.container_top;
                left = mouse.x;
                top = event_state.container_top;
            } else if ($(event_state.evnt.target).hasClass('resize-handle-nw')) {
                width = event_state.container_width - (mouse.x - event_state.container_left);
                height = event_state.container_height - (mouse.y - event_state.container_top);
                left = mouse.x;
                top = mouse.y;
                if (constrain || e.shiftKey) {
                    top = mouse.y - ((width / orig_src.width * orig_src.height) - height);
                }
            } else if ($(event_state.evnt.target).hasClass('resize-handle-ne')) {
                width = mouse.x - event_state.container_left;
                height = event_state.container_height - (mouse.y - event_state.container_top);
                left = event_state.container_left;
                top = mouse.y;
                if (constrain || e.shiftKey) {
                    top = mouse.y - ((width / orig_src.width * orig_src.height) - height);
                }
            }

            // Optionally maintain aspect ratio
            if (constrain || e.shiftKey) {
                height = width / orig_src.width * orig_src.height;
            }

            if (width > min_width && height > min_height && width < max_width && height < max_height) {
                // To improve performance you might limit how often resizeImage() is called
                resizeImage(width, height);
                // Without this Firefox will not re-calculate the the image dimensions until drag end
                $container.offset({
                    'left': left,
                    'top': top
                });
            }
        }

        resizeImage = function(width, height) {
            resize_canvas.width = width;
            resize_canvas.height = height;
            resize_canvas.getContext('2d').drawImage(orig_src, 0, 0, width, height);
            $(image_target).attr('src', resize_canvas.toDataURL("image/png"));
        };

        startMoving = function(e) {
            e.preventDefault();
            e.stopPropagation();
            saveEventState(e);
            $(document).on('mousemove touchmove', moving);
            $(document).on('mouseup touchend', endMoving);
        };

        endMoving = function(e) {
            e.preventDefault();
            $(document).off('mouseup touchend', endMoving);
            $(document).off('mousemove touchmove', moving);
        };

        moving = function(e) {
            var mouse = {},
                touches;
            e.preventDefault();
            e.stopPropagation();

            touches = e.originalEvent.touches;

            mouse.x = (e.clientX || e.pageX || touches[0].clientX) + $(window).scrollLeft();
            mouse.y = (e.clientY || e.pageY || touches[0].clientY) + $(window).scrollTop();
            $container.offset({
                'left': mouse.x - (event_state.mouse_x - event_state.container_left),
                'top': mouse.y - (event_state.mouse_y - event_state.container_top)
            });
            // Watch for pinch zoom gesture while moving
            if (event_state.touches && event_state.touches.length > 1 && touches.length > 1) {
                var width = event_state.container_width,
                    height = event_state.container_height;
                var a = event_state.touches[0].clientX - event_state.touches[1].clientX;
                a = a * a;
                var b = event_state.touches[0].clientY - event_state.touches[1].clientY;
                b = b * b;
                var dist1 = Math.sqrt(a + b);

                a = e.originalEvent.touches[0].clientX - touches[1].clientX;
                a = a * a;
                b = e.originalEvent.touches[0].clientY - touches[1].clientY;
                b = b * b;
                var dist2 = Math.sqrt(a + b);

                var ratio = dist2 / dist1;

                width = width * ratio;
                height = height * ratio;
                // To improve performance you might limit how often resizeImage() is called
                resizeImage(width, height);
            }
        };

        crop = function() {
            //Find the part of the image that is inside the crop box
            var crop_canvas,
                left = $('.signature-overlay').offset().left - $container.offset().left,
                top = $('.signature-overlay').offset().top - $container.offset().top,
                width = $('.signature-overlay').width(),
                height = $('.signature-overlay').height();

            crop_canvas = document.createElement('canvas');
            crop_canvas.width = width;
            crop_canvas.height = height;

            crop_canvas.getContext('2d').drawImage(image_target, left, top, width, height, 0, 0, width, height);
            //window.open(crop_canvas.toDataURL("image/png"));
            document.getElementById('croppedImg').src = crop_canvas.toDataURL("image/png");
        }

        init();
    };

    //---- Listeners

    $scope.$on("$destroy", function() {

        //Dynamsoft.WebTwainEnv.UnLoad();
    });

    $scope.Dynamsoft_OnPostTransfer = function()
    {
        $scope.Cropped = true;
    }

    $scope.Dynamsoft_OnImageAreaSelected = function(index, left, top, right, bottom) 
    {
        $scope.ImagePosition.Left = left;
        $scope.ImagePosition.Top = top;
        $scope.ImagePosition.Right = right;
        $scope.ImagePosition.Bottom = bottom;
    }

    $scope.Dynamsoft_OnImageAreaDeselected = function(index) 
    {
         $scope.ImagePosition.Initialise();
    }

    //------------------------------------------------------------------------------------

}]);