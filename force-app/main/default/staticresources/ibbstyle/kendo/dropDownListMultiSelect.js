
//MultiSelect - A user extension of KendoUI DropDownList widget.           
(function ($) {

    // shorten references to variables
    var kendo = window.kendo2014,
        ui = kendo.ui,
        DropDownList = ui.DropDownList,
        keys = kendo.keys,
        SELECT = "select",
        SELECTIONCHANGED = "selectionChanged",
        SELECTED = "k-state-selected",
        HIGHLIGHTED = "k-state-active",
        CHECKBOX = "custom-multiselect-check-item",
        SELECTALLITEM = "custom-multiselect-selectAll-item",
        MULTISELECTPOPUP = "custom-multiselect-popup",
        EMPTYSELECTION = "custom-multiselect-summary-empty";



    var lineTemplate = '<input type="checkbox" name="#= {1} #" value="#= {0} #" class="' + CHECKBOX + '" />' +
                       '<span data-value="#= {0} #">#= {1} #</span>';



    var MultiSelectBox = DropDownList.extend({

        init: function (element, options) {

            options.template = kendo.template(kendo.format(options.template, options.dataValueField, options.dataTextField));

            // base call to widget initialization
            DropDownList.fn.init.call(this, element, options);
        },

        options: {
            name: "MultiSelectBox",
            index: -1,
            showSelectAll: false,
            preSummaryCount: 1,  // number of items to show before summarising
            emptySelectionLabel: '',  // what to show when no items are selected
            selectionChanged: null // provide callback to invoke when selection has changed
        },

        events: [
            SELECTIONCHANGED
        ],

        refresh: function () {

            // base call
            DropDownList.fn.refresh.call(this);

            this._updateSummary();

            $(this.popup.element).addClass(MULTISELECTPOPUP);
        },


        current: function (candidate) {
            return this._current;
        },


        open: function () {
            this._removeSelectAllItem();

            this._addSelectAllItem();

            DropDownList.fn.open.call(this);

            //hook on to popup event because dropdown close does not
            //fire consistently when user clicks on some other elements
            //like a dataviz chart graphic
            this.popup.one('close', $.proxy(this._onPopupClosed, this));
        },

        _onPopupClosed: function () {

            this._removeSelectAllItem();

            this._current = null;
            //this._highlightCurrent();

            this._raiseSelectionChanged();
        },

        _raiseSelectionChanged: function () {

            var currentValue = this.value();
            var currentValues = $.map((currentValue.length > 0 ? currentValue.split(",") : []).sort(), function (item) { return item.toString(); });
            var oldValues = $.map((this._oldValue || []).sort(), function (item) { return item.toString(); });

            // store for next pass
            this._oldValue = $.map(currentValues, function (item) { return item.toString(); });

            var changedArgs = { newValue: currentValues, oldValue: oldValues };

            if (oldValues) {

                var hasChanged = ($(oldValues).not(currentValues).length == 0 && $(currentValues).not(oldValues).length == 0) !== true;

                if (hasChanged) {
                    //if (this.options.selectionChanged)
                    //    this.options.selectionChanged(changedArgs);
                    this.trigger(SELECTIONCHANGED, changedArgs);
                }
            }
            else if (currentValue.length > 0) {
                //if (this.options.selectionChanged)
                //    this.options.selectionChanged(changedArgs);
                this.trigger(SELECTIONCHANGED, changedArgs);
            }
        },

        _addSelectAllItem: function () {

            if (!this.options.showSelectAll) return;

            var firstListItem = this.ul.children('li:first');

            if (firstListItem.length > 0) {
                this.selectAllListItem = $('<li tabindex="-1" role="option" unselectable="on" class="k-item ' + SELECTALLITEM + '"></li>').insertBefore(firstListItem);

                // fake a data object to use for the template binding below
                var selectAllData = {};
                selectAllData[this.options.dataValueField] = '*';
                selectAllData[this.options.dataTextField] = 'All';

                this.selectAllListItem.html(this.options.template(selectAllData));

                this._updateSelectAllItem();

                this._makeUnselectable(); // required for IE8
            }
        },


        _removeSelectAllItem: function () {

            if (this.selectAllListItem) {
                this.selectAllListItem.remove();
            }
            this.selectAllListItem = null;
        },


        _focus: function (li) {
            if (this.popup.visible() && li && this.trigger(SELECT, { item: li })) {
                this.close();
                return;
            }
            this.select(li);
        },


        //_highlightCurrent: function () {

        //    $('li', this.ul).removeClass(HIGHLIGHTED);
        //    $(this._current).addClass(HIGHLIGHTED);
        //},


        _keydown: function (e) {

            // currently ignore Home and End keys
            // can be added later
            if (e.keyCode == kendo.keys.HOME ||
                e.keyCode == kendo.keys.END) {
                e.preventDefault();
                return;
            }

            DropDownList.fn._keydown.call(this, e);
        },

        _keypress: function(e) {
            // disable existing function
        },

        _move: function (e) {
            var that = this,
                key = e.keyCode,
                ul = that.ul[0],
                down = key === keys.DOWN,
                pressed;

            if (key === keys.UP || down) {

                if (down) {

                    if (!that.popup.visible()) {
                        that.toggle(down);
                    }
                    if (!that._current) {
                        that._current = ul.firstChild;
                    } else {
                        that._current = ($(that._current)[0].nextSibling || that._current);
                    }

                } else {
                    //up

                    // only if anything is highlighted
                    if (that._current) {
                        that._current = ($(that._current)[0].previousSibling || ul.firstChild);
                    }
                }


                if (that._current) {
                    that._scroll(that._current);
                }

                that._highlightCurrent();

                e.preventDefault();
                pressed = true;

            } else {
                pressed = DropDownList.fn._move.call(this, e);
            }

            return pressed;
        },


        selectAll: function () {

            var unselectedItems = this._getUnselectedListItems();
            this._selectItems(unselectedItems);

            // todo: raise custom event
        },

        unselectAll: function () {

            var selectedItems = this._getSelectedListItems();
            this._selectItems(selectedItems);  // will invert the selection

            // todo: raise custom event
        },


        _selectItems: function (listItems) {
            var that = this;

            $.each(listItems, function (i, item) {
                var idx = ui.List.inArray(item, that.ul[0]);
                that.select(idx);  // select OR unselect
            });
			delete this._none;
        },

        _selectItem: function () {
            // method override to prevent default selection of first item, done by normal dropdown
            var that = this,
                options = that.options,
                useOptionIndex,
                value;

            useOptionIndex = that._isSelect && !that._initial && !options.value && options.index && !that._bound;

            if (!useOptionIndex) {
                value = that._selectedValue || options.value || that._accessor();
            }

            if (value) {
                that.value(value);
            } else if (that._bound === undefined) {
                that.select(options.index);
            }
        },

        _select: function (li) {
            var that = this,
                 value,
                 text,
                 idx;

            li = that._get(li);

            if (li && li[0]) {
                idx = ui.List.inArray(li[0], that.ul[0]);
                if (idx > -1) {

                    if (li.hasClass(SELECTED)) {
                        li.removeClass(SELECTED);
                        that._uncheckItem(li);

                        if (this.selectAllListItem && li[0] === this.selectAllListItem[0]) {
                            this.unselectAll();
                        }
                    } else {
                        li.addClass(SELECTED);
                        that._checkItem(li);

                        if (this.selectAllListItem && li[0] === this.selectAllListItem[0]) {
                            this.selectAll();
                        }
                    }

                    if (this._open) {
                        that._current(li);
                        that._highlightCurrent();
                    }

                    var selecteditems = this._getSelectedListItems();
                    value = [];
                    text = [];
                    $.each(selecteditems, function (indx, item) {
                        //var obj = $(item).children("span").first();
                        value.push($(item).find("input").val());
                        text.push($(item).find("input").attr("name"));
                    });

                    that._updateSummary(text);

                    that._updateSelectAllItem();

                    that._accessor(value, idx);

                    // todo: raise change event (add support for selectedIndex) if required
                }
            }
			if(!this._none){
				this._none = true;
				if($(li) && ($(li).text()).indexOf("--None--") > -1){
					var selectedItems = this._getSelectedListItems();
					selectedItems = this.ul.children("li").not($(this.ul.children('li'))[0]).filter("." + SELECTED);
					this._selectItems(selectedItems);
					this.close();
					return;
				}else{
					var selectedItems = this._getSelectedListItems();
					selectedItems = [li];
					if($(this.ul.children('li')[0]).filter("." + SELECTED).length > 0){
						selectedItems.push($(this.ul.children('li')[0]).filter("." + SELECTED)[0]);
					}
					this._selectItems(selectedItems);
				}
			}
        },

        _getAllValueListItems: function () {
            if (this.selectAllListItem) {
                return this.ul.children("li").not(this.selectAllListItem[0]);
            } else {
                return this.ul.children("li");
            }
        },

        _getSelectedListItems: function () {
            return this._getAllValueListItems().filter("." + SELECTED);
        },

        _getUnselectedListItems: function () {
            return this._getAllValueListItems().filter(":not(." + SELECTED + ")");
        },

        _getSelectedItemsText: function () {

            var text = [];
            var selecteditems = this._getSelectedListItems();
            $.each(selecteditems, function (indx, item) {
                //var obj = $(item).children("span").first();
                text.push($(item).find("input").attr("name"));
            });
            return text;
        },

        _updateSelectAllItem: function () {

            if (!this.selectAllListItem) return;

            // are all items selected?
            if (this._getAllValueListItems().length == this._getSelectedListItems().length) {
                this._checkItem(this.selectAllListItem);
                this.selectAllListItem.addClass(SELECTED);
            }
            else {
                this._uncheckItem(this.selectAllListItem);
                this.selectAllListItem.removeClass(SELECTED);
            }
        },

        _updateSummary: function (itemsText) {

            if (!itemsText) {
                itemsText = this._getSelectedItemsText();
            }

            if (itemsText.length == 0) {
                this._inputWrapper.addClass(EMPTYSELECTION);
                this.text(this.options.emptySelectionLabel);
                return;
            } else {
                this._inputWrapper.removeClass(EMPTYSELECTION);
            }

            if (itemsText.length <= this.options.preSummaryCount) {
                this._textAccessor(itemsText.join(", "));
            }
            else {
                this._textAccessor(itemsText);
            }
        },

        _checkItem: function (itemContainer) {
            if (!itemContainer) return;
            itemContainer.find("input").prop("checked", true);
        },

        _uncheckItem: function (itemContainer) {
            if (!itemContainer) return;
            itemContainer.find("input").removeAttr("checked");
        },

        _isItemChecked: function (itemContainer) {
            return itemContainer.find("input:checked").length > 0;
        },

        value: function (value) {
            var that = this,
                idx,
                valuesList = [];

            if (value !== undefined) {

                if (!$.isArray(value)) {
                    valuesList.push(value);
                    this._oldValue = valuesList; // to allow for selectionChanged event
                }
                else {
                    valuesList = value;
                    this._oldValue = value; // to allow for selectionChanged event
                }

                // clear all selections first
                $(that.ul[0]).children("li").removeClass(SELECTED);
                $("input", that.ul[0]).removeAttr("checked");

                $.each(valuesList, function (indx, item) {

                    var hasValue;
                    
                    if (item !== null) {
                        item = item.toString();
                    }

                    that._selectedValue = item;

                    hasValue = value || (that.options.optionLabel && !that.element[0].disabled && value === "");
                    if (hasValue && that._fetchItems(value)) {
                        return;
                    }

                    idx = that._index(item);

                    if (idx > -1) {
                        that.select(idx);
                    }
                });

                that._updateSummary();
            }
            else {
                var selecteditems = this._getSelectedListItems();
                return $.map(selecteditems, function(item) {
                    //var obj = $(item).children("span").first();
                    return $(item).find("input").val();
                }).join();
            }
        },

    });

    ui.plugin(MultiSelectBox);

})(jQuery);         